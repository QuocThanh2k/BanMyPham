const { sql, connectDB } = require("../config/database");

async function getOverview() {
  const pool = await connectDB();
  const { recordset } = await pool.request().query(
    `SELECT
       (SELECT COUNT(*) FROM dbo.SanPham WHERE TrangThai = 1) AS activeProducts,
       (SELECT COUNT(*) FROM dbo.SanPham WHERE TrangThai = 1 AND SoLuongKho <= 5) AS lowStockProducts,
       (SELECT COUNT(*) FROM dbo.KhachHang WHERE VaiTro = N'customer') AS customers,
       (SELECT COUNT(*) FROM dbo.DonHang WHERE TrangThai IN (N'pending', N'confirmed')) AS openOrders,
       (SELECT COUNT(*) FROM dbo.DonHang) AS totalOrders,
       (SELECT COALESCE(SUM(TongThanhToan), 0) FROM dbo.DonHang WHERE TrangThai <> N'cancelled') AS revenue`,
  );
  return recordset[0];
}

async function listProducts({ search, includeInactive = true, limit = 500, offset = 0 } = {}) {
  const pool = await connectDB();
  const request = pool.request()
    .input("limit", sql.Int, limit)
    .input("offset", sql.Int, offset);
  const conditions = [];
  if (!includeInactive) conditions.push("sp.TrangThai = 1");
  if (search) {
    conditions.push("(sp.TenSanPham LIKE @search OR sp.Slug LIKE @search)");
    request.input("search", sql.NVarChar(255), `%${search}%`);
  }
  const { recordset } = await request.query(
    `SELECT sp.MaSanPham AS id, sp.Slug AS slug, sp.TenSanPham AS name,
       sp.Gia AS price, sp.GiaGoc AS originalPrice, sp.SoLuongKho AS stock,
       sp.LinkAnh AS imageUrl, sp.MaDanhMuc AS categoryId, sp.MaThuongHieu AS brandId,
       sp.MaLoaiDa AS skinTypeId, sp.MoTa AS description, sp.DanhGia AS rating,
       sp.HanSuDung AS expiresAt, sp.TrangThai AS isActive,
       dm.TenDanhMuc AS categoryName, th.TenThuongHieu AS brandName
     FROM dbo.SanPham sp
     LEFT JOIN dbo.DanhMuc dm ON dm.MaDanhMuc = sp.MaDanhMuc
     LEFT JOIN dbo.ThuongHieu th ON th.MaThuongHieu = sp.MaThuongHieu
     ${conditions.length ? `WHERE ${conditions.join(" AND ")}` : ""}
     ORDER BY sp.MaSanPham DESC
     OFFSET @offset ROWS FETCH NEXT @limit ROWS ONLY`,
  );
  return recordset;
}

async function listCatalogOptions() {
  const pool = await connectDB();
  const [categories, brands, skinTypes] = await Promise.all([
    pool.request().query(
      "SELECT MaDanhMuc AS id, TenDanhMuc AS name FROM dbo.DanhMuc WHERE TrangThai = 1 ORDER BY TenDanhMuc",
    ),
    pool.request().query(
      "SELECT MaThuongHieu AS id, TenThuongHieu AS name FROM dbo.ThuongHieu WHERE TrangThai = 1 ORDER BY TenThuongHieu",
    ),
    pool.request().query(
      "SELECT MaLoaiDa AS id, TenLoaiDa AS name FROM dbo.LoaiDa WHERE TrangThai = 1 ORDER BY TenLoaiDa",
    ),
  ]);
  return { categories: categories.recordset, brands: brands.recordset, skinTypes: skinTypes.recordset };
}

function addProductInputs(request, product) {
  return request
    .input("name", sql.NVarChar(255), product.name)
    .input("slug", sql.NVarChar(255), product.slug)
    .input("description", sql.NVarChar(sql.MAX), product.description || null)
    .input("price", sql.Decimal(12, 2), product.price)
    .input("originalPrice", sql.Decimal(12, 2), product.originalPrice)
    .input("stock", sql.Int, product.stock)
    .input("imageUrl", sql.NVarChar(2048), product.imageUrl || null)
    .input("categoryId", sql.BigInt, product.categoryId)
    .input("brandId", sql.BigInt, product.brandId)
    .input("skinTypeId", sql.BigInt, product.skinTypeId)
    .input("expiresAt", sql.Date, product.expiresAt);
}

async function createProduct(product) {
  const pool = await connectDB();
  const request = addProductInputs(pool.request(), product);
  const { recordset } = await request.query(
    `INSERT INTO dbo.SanPham
       (TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, HanSuDung)
     OUTPUT INSERTED.MaSanPham AS id
     VALUES (@name, @slug, @description, @price, @originalPrice, @stock, @imageUrl, @categoryId, @brandId, @skinTypeId, @expiresAt)`,
  );
  return recordset[0];
}

async function updateProduct(id, product) {
  const pool = await connectDB();
  const request = addProductInputs(pool.request(), product).input("id", sql.BigInt, id);
  const { rowsAffected } = await request.query(
    `UPDATE dbo.SanPham
     SET TenSanPham = @name, Slug = @slug, MoTa = @description, Gia = @price,
       GiaGoc = @originalPrice, SoLuongKho = @stock, LinkAnh = @imageUrl,
       MaDanhMuc = @categoryId, MaThuongHieu = @brandId, MaLoaiDa = @skinTypeId,
       HanSuDung = @expiresAt
     WHERE MaSanPham = @id AND TrangThai = 1`,
  );
  return rowsAffected[0] === 1;
}

async function archiveProduct(id) {
  const pool = await connectDB();
  const { rowsAffected } = await pool.request()
    .input("id", sql.BigInt, id)
    .query("UPDATE dbo.SanPham SET TrangThai = 0 WHERE MaSanPham = @id AND TrangThai = 1");
  return rowsAffected[0] === 1;
}

async function restoreProduct(id) {
  const pool = await connectDB();
  const { rowsAffected } = await pool.request()
    .input("id", sql.BigInt, id)
    .query("UPDATE dbo.SanPham SET TrangThai = 1 WHERE MaSanPham = @id AND TrangThai = 0");
  return rowsAffected[0] === 1;
}

async function listUsers() {
  const pool = await connectDB();
  const { recordset } = await pool.request().query(
    `SELECT MaKhachHang AS id, HoTen AS fullName, Email AS email,
       SoDienThoai AS phone, DiaChi AS address,
       CASE WHEN LOWER(Email) = N'quocthanh2614@gmail.com' THEN N'super_admin' ELSE VaiTro END AS role,
       TaiKhoanHoatDong AS isActive, NgayTao AS createdAt
     FROM dbo.KhachHang ORDER BY NgayTao DESC`,
  );
  return recordset;
}

async function updateUser(id, { role, isActive, actorRole }) {
  const pool = await connectDB();
  const { recordset } = await pool.request()
    .input("id", sql.BigInt, id)
    .input("role", sql.NVarChar(20), role)
    .input("isActive", sql.Bit, isActive)
    .input("actorRole", sql.NVarChar(20), actorRole)
    .query(
      `UPDATE dbo.KhachHang
       SET VaiTro = COALESCE(@role, VaiTro),
         TaiKhoanHoatDong = COALESCE(@isActive, TaiKhoanHoatDong)
       OUTPUT INSERTED.MaKhachHang AS id, INSERTED.HoTen AS fullName,
         INSERTED.Email AS email, INSERTED.VaiTro AS role,
         INSERTED.TaiKhoanHoatDong AS isActive
       WHERE MaKhachHang = @id
         AND VaiTro <> N'super_admin'
         AND LOWER(Email) <> N'quocthanh2614@gmail.com'
         AND (@actorRole = N'super_admin' OR VaiTro = N'customer')`,
    );
  return recordset[0] || null;
}

async function listOrders() {
  const pool = await connectDB();
  const { recordset } = await pool.request().query(
    `SELECT d.MaDonHang AS id, d.TrangThai AS status, d.TongTienHang AS subtotal,
       d.PhiVanChuyen AS shippingFee, d.TongThanhToan AS total,
       d.PhuongThucThanhToan AS paymentMethod, d.NgayDat AS createdAt,
       COUNT(ct.MaChiTiet) AS itemCount
     FROM dbo.DonHang d
     LEFT JOIN dbo.ChiTietDonHang ct ON ct.MaDonHang = d.MaDonHang
     GROUP BY d.MaDonHang, d.TrangThai, d.TongTienHang, d.PhiVanChuyen,
       d.TongThanhToan, d.PhuongThucThanhToan, d.NgayDat
     ORDER BY d.NgayDat DESC`,
  );
  return recordset;
}

async function changeOrderStatus(id, status) {
  const pool = await connectDB();
  const transaction = new sql.Transaction(pool);
  await transaction.begin();
  try {
    const { recordset } = await new sql.Request(transaction)
      .input("id", sql.BigInt, id)
      .query("SELECT TrangThai AS status FROM dbo.DonHang WITH (UPDLOCK, HOLDLOCK) WHERE MaDonHang = @id");
    const currentStatus = recordset[0]?.status;
    if (!currentStatus) {
      await transaction.rollback();
      return { kind: "not_found" };
    }
    const allowedTransitions = {
      pending: ["confirmed", "cancelled"],
      confirmed: ["shipped", "cancelled"],
      shipped: ["completed"],
      completed: [],
      cancelled: [],
    };
    if (!allowedTransitions[currentStatus]?.includes(status)) {
      await transaction.rollback();
      return { kind: "invalid_transition", currentStatus };
    }
    if (status === "cancelled") {
      await new sql.Request(transaction)
        .input("id", sql.BigInt, id)
        .query(
          `UPDATE sp
           SET sp.SoLuongKho = sp.SoLuongKho + ct.SoLuong
           FROM dbo.SanPham sp
           INNER JOIN dbo.ChiTietDonHang ct ON ct.MaSanPham = sp.MaSanPham
           WHERE ct.MaDonHang = @id`,
        );
    }
    await new sql.Request(transaction)
      .input("id", sql.BigInt, id)
      .input("status", sql.NVarChar(20), status)
      .query("UPDATE dbo.DonHang SET TrangThai = @status WHERE MaDonHang = @id");
    await transaction.commit();
    return { kind: "updated" };
  } catch (error) {
    await transaction.rollback();
    throw error;
  }
}

module.exports = {
  getOverview,
  listProducts,
  listCatalogOptions,
  createProduct,
  updateProduct,
  archiveProduct,
  restoreProduct,
  listUsers,
  updateUser,
  listOrders,
  changeOrderStatus,
};
