const { sql, connectDB } = require("../config/database");

async function create({ items, paymentMethod, discountCode }) {
  const pool = await connectDB();
  const transaction = new sql.Transaction(pool);
  let transactionStarted = false;

  try {
    await transaction.begin();
    transactionStarted = true;
    let subtotalCents = 0;
    const orderItems = [];

    for (const item of items) {
      const { recordset } = await new sql.Request(transaction)
        .input("productId", sql.BigInt, item.productId)
        .query(
          `SELECT MaSanPham, TenSanPham, Gia, SoLuongKho
           FROM SanPham WITH (UPDLOCK, HOLDLOCK)
           WHERE MaSanPham = @productId`,
        );
      const product = recordset[0];
      if (!product || product.SoLuongKho < item.quantity) {
        const error = new Error(`Sản phẩm ${item.productId} không tồn tại hoặc không đủ hàng`);
        error.status = 400;
        throw error;
      }
      const unitPriceCents = Math.round(Number(product.Gia) * 100);
      subtotalCents += unitPriceCents * item.quantity;
      orderItems.push({ ...item, unitPrice: product.Gia, lineTotalCents: unitPriceCents * item.quantity });
    }

    let discountCents = 0;
    if (discountCode) {
      const { recordset } = await new sql.Request(transaction)
        .input("discountCode", sql.NVarChar(50), discountCode)
        .query(
          `SELECT LoaiGiamGia AS type, GiaTri AS value, NgayBatDau AS startsAt,
             NgayKetThuc AS endsAt, SoLuong AS remainingUses, TrangThai AS enabled
           FROM MaGiamGia WITH (UPDLOCK, HOLDLOCK)
           WHERE MaCode = @discountCode`,
        );
      const discount = recordset[0];
      const now = Date.now();
      if (!discount || !discount.enabled ||
          (discount.startsAt && new Date(discount.startsAt).getTime() > now) ||
          (discount.endsAt && new Date(discount.endsAt).getTime() < now) ||
          (discount.remainingUses !== null && discount.remainingUses < 1)) {
        const error = new Error("Mã giảm giá không hợp lệ hoặc đã hết hạn");
        error.status = 400;
        throw error;
      }
      const value = Number(discount.value);
      if (!Number.isFinite(value) || value <= 0 || (discount.type === "percent" && value > 100)) {
        const error = new Error("Mã giảm giá có cấu hình không hợp lệ");
        error.status = 400;
        throw error;
      }
      discountCents = discount.type === "percent"
        ? Math.round(subtotalCents * value / 100)
        : Math.min(subtotalCents, Math.round(value * 100));
      if (discount.remainingUses !== null) {
        const result = await new sql.Request(transaction)
          .input("discountCode", sql.NVarChar(50), discountCode)
          .query(
            `UPDATE MaGiamGia
             SET SoLuong = SoLuong - 1
             WHERE MaCode = @discountCode AND SoLuong > 0`,
          );
        if (result.rowsAffected[0] !== 1) {
          const error = new Error("Mã giảm giá đã hết lượt sử dụng");
          error.status = 400;
          throw error;
        }
      }
    }

    const subtotal = subtotalCents / 100;
    const shippingFee = subtotal >= 500000 ? 0 : 30000;
    const total = (subtotalCents - discountCents) / 100 + shippingFee;
    const { recordset: orderRecordset } = await new sql.Request(transaction)
      .input("discountCode", sql.NVarChar(50), discountCode || null)
      .input("subtotal", sql.Decimal(12, 2), subtotal)
      .input("shippingFee", sql.Decimal(12, 2), shippingFee)
      .input("total", sql.Decimal(12, 2), total)
      .input("paymentMethod", sql.NVarChar(20), paymentMethod)
      .query(
        `INSERT INTO DonHang
          (MaKhachHang, TrangThai, MaGiamGiaCode, TongTienHang, PhiVanChuyen, TongThanhToan, PhuongThucThanhToan)
         OUTPUT INSERTED.MaDonHang AS id
         VALUES (NULL, N'pending', @discountCode, @subtotal, @shippingFee, @total, @paymentMethod)`,
      );
    const orderId = orderRecordset[0].id;

    let allocatedDiscountCents = 0;
    for (const [index, item] of orderItems.entries()) {
      const itemDiscountCents = discountCents === 0
        ? 0
        : index === orderItems.length - 1
        ? discountCents - allocatedDiscountCents
        : Math.floor(discountCents * item.lineTotalCents / subtotalCents);
      allocatedDiscountCents += itemDiscountCents;
      await new sql.Request(transaction)
        .input("orderId", sql.BigInt, orderId)
        .input("productId", sql.BigInt, item.productId)
        .input("quantity", sql.Int, item.quantity)
        .input("unitPrice", sql.Decimal(12, 2), item.unitPrice)
        .input("discount", sql.Decimal(12, 2), itemDiscountCents / 100)
        .query(
          `INSERT INTO ChiTietDonHang (MaDonHang, MaSanPham, SoLuong, GiaDonVi, GiamGia)
           VALUES (@orderId, @productId, @quantity, @unitPrice, @discount)`,
        );
      const updateResult = await new sql.Request(transaction)
        .input("quantity", sql.Int, item.quantity)
        .input("productId", sql.BigInt, item.productId)
        .query(
          `UPDATE SanPham
           SET SoLuongKho = SoLuongKho - @quantity
           WHERE MaSanPham = @productId AND SoLuongKho >= @quantity`,
        );
      if (updateResult.rowsAffected[0] !== 1) {
        const error = new Error(`Sản phẩm ${item.productId} không còn đủ hàng`);
        error.status = 400;
        throw error;
      }
    }

    await transaction.commit();
    transactionStarted = false;
    return { id: orderId, subtotal, discount: discountCents / 100, shippingFee, total };
  } catch (error) {
    if (transactionStarted) await transaction.rollback();
    throw error;
  }
}

module.exports = { create };
