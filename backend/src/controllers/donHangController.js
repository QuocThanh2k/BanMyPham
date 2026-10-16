const orderModel = require("../models/donHangModel");

async function create(req, res, next) {
  try {
    const { items, paymentMethod, discountCode } = req.body;
    if (!Array.isArray(items) || items.length === 0 || items.length > 100) {
      return res.status(400).json({ error: "Đơn hàng phải có từ 1 đến 100 sản phẩm" });
    }
    if (paymentMethod === "stripe") {
      return res.status(501).json({ error: "Thanh toán Stripe chưa được cấu hình" });
    }
    if (paymentMethod !== "cod") {
      return res.status(400).json({ error: "Phương thức thanh toán không hợp lệ" });
    }
    if (discountCode !== undefined && (typeof discountCode !== "string" || discountCode.trim() === "")) {
      return res.status(400).json({ error: "Mã giảm giá không hợp lệ" });
    }
    const quantitiesByProduct = new Map();
    for (const item of items) {
      const productId = Number(item.productId);
      const quantity = Number(item.quantity);
      if (!Number.isSafeInteger(productId) || productId < 1 || !Number.isSafeInteger(quantity) || quantity < 1 || quantity > 1000) {
        return res.status(400).json({ error: "Sản phẩm hoặc số lượng không hợp lệ" });
      }
      const combinedQuantity = (quantitiesByProduct.get(productId) || 0) + quantity;
      if (combinedQuantity > 1000) return res.status(400).json({ error: "Số lượng mỗi sản phẩm không được vượt quá 1000" });
      quantitiesByProduct.set(productId, combinedQuantity);
    }
    const normalizedItems = Array.from(quantitiesByProduct, ([productId, quantity]) => ({ productId, quantity }));
    const order = await orderModel.create({
      items: normalizedItems,
      paymentMethod,
      discountCode: typeof discountCode === "string" ? discountCode.trim().toUpperCase() : null,
    });
    res.status(201).json({ data: order });
  } catch (error) {
    next(error);
  }
}

module.exports = { create };
