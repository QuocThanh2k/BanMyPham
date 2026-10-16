const adminModel = require("../models/adminModel");

const ORDER_STATUSES = ["pending", "confirmed", "shipped", "completed", "cancelled"];

function parseId(value) {
  const id = Number(value);
  return Number.isSafeInteger(id) && id > 0 ? id : null;
}

function parseOptionalId(value, field) {
  if (value === undefined || value === null || value === "") return null;
  const id = Number(value);
  if (!Number.isSafeInteger(id) || id < 1) throw new Error(`${field} không hợp lệ`);
  return id;
}

function validateProduct(body) {
  const name = typeof body.name === "string" ? body.name.trim() : "";
  const slug = typeof body.slug === "string" ? body.slug.trim().toLowerCase() : "";
  const price = Number(body.price);
  const originalPrice = body.originalPrice === "" || body.originalPrice === null
    || body.originalPrice === undefined ? null : Number(body.originalPrice);
  const stock = Number(body.stock);
  const imageUrl = typeof body.imageUrl === "string" ? body.imageUrl.trim() : "";
  const description = typeof body.description === "string" ? body.description.trim() : "";
  const expiresAt = typeof body.expiresAt === "string" && body.expiresAt
    ? body.expiresAt
    : null;

  if (!name || name.length > 255) throw new Error("Tên sản phẩm phải có từ 1 đến 255 ký tự");
  if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(slug) || slug.length > 255) {
    throw new Error("Đường dẫn sản phẩm chỉ gồm chữ thường không dấu, số và dấu gạch ngang");
  }
  if (!Number.isFinite(price) || price < 0 || price > 9999999999.99) {
    throw new Error("Giá bán không hợp lệ");
  }
  if (originalPrice !== null && (!Number.isFinite(originalPrice)
      || originalPrice < 0 || originalPrice > 9999999999.99)) {
    throw new Error("Giá gốc không hợp lệ");
  }
  if (!Number.isSafeInteger(stock) || stock < 0 || stock > 2147483647) {
    throw new Error("Số lượng tồn kho không hợp lệ");
  }
  if (imageUrl.length > 2048 || description.length > 10000) {
    throw new Error("Ảnh hoặc mô tả sản phẩm vượt quá giới hạn");
  }
  if (expiresAt && !/^\d{4}-\d{2}-\d{2}$/.test(expiresAt)) {
    throw new Error("Hạn sử dụng không hợp lệ");
  }
  if (expiresAt) {
    const expirationDate = new Date(`${expiresAt}T00:00:00.000Z`);
    if (Number.isNaN(expirationDate.getTime()) || expirationDate.toISOString().slice(0, 10) !== expiresAt) {
      throw new Error("Hạn sử dụng không hợp lệ");
    }
  }
  return {
    name,
    slug,
    description,
    price,
    originalPrice,
    stock,
    imageUrl,
    categoryId: parseOptionalId(body.categoryId, "Danh mục"),
    brandId: parseOptionalId(body.brandId, "Thương hiệu"),
    skinTypeId: parseOptionalId(body.skinTypeId, "Loại da"),
    expiresAt,
  };
}

function validationError(res, error) {
  if (error.message.endsWith("không hợp lệ") || error.message.includes("phải có")
      || error.message.includes("chỉ gồm") || error.message.includes("vượt quá")) {
    res.status(400).json({ error: error.message });
    return true;
  }
  return false;
}

async function overview(_req, res, next) {
  try {
    res.json({ data: await adminModel.getOverview() });
  } catch (error) {
    next(error);
  }
}

async function listProducts(req, res, next) {
  try {
    const search = typeof req.query.search === "string" ? req.query.search.trim() : "";
    if (search.length > 255) return res.status(400).json({ error: "Từ khóa tìm kiếm quá dài" });
    const data = await adminModel.listProducts({ search: search || undefined, limit: 500 });
    res.json({ data });
  } catch (error) {
    next(error);
  }
}

async function catalogOptions(_req, res, next) {
  try {
    res.json({ data: await adminModel.listCatalogOptions() });
  } catch (error) {
    next(error);
  }
}

async function createProduct(req, res, next) {
  try {
    let product;
    try {
      product = validateProduct(req.body || {});
    } catch (error) {
      if (validationError(res, error)) return;
      throw error;
    }
    const created = await adminModel.createProduct(product);
    res.status(201).json({ data: created });
  } catch (error) {
    if (error.number === 2601 || error.number === 2627) {
      return res.status(409).json({ error: "Đường dẫn sản phẩm đã tồn tại" });
    }
    if (error.number === 547) {
      return res.status(400).json({ error: "Danh mục, thương hiệu hoặc loại da không tồn tại" });
    }
    next(error);
  }
}

async function updateProduct(req, res, next) {
  const id = parseId(req.params.id);
  if (!id) return res.status(400).json({ error: "Mã sản phẩm không hợp lệ" });
  try {
    let product;
    try {
      product = validateProduct(req.body || {});
    } catch (error) {
      if (validationError(res, error)) return;
      throw error;
    }
    if (!(await adminModel.updateProduct(id, product))) {
      return res.status(404).json({ error: "Không tìm thấy sản phẩm đang hoạt động" });
    }
    res.json({ data: { id } });
  } catch (error) {
    if (error.number === 2601 || error.number === 2627) {
      return res.status(409).json({ error: "Đường dẫn sản phẩm đã tồn tại" });
    }
    if (error.number === 547) {
      return res.status(400).json({ error: "Danh mục, thương hiệu hoặc loại da không tồn tại" });
    }
    next(error);
  }
}

async function archiveProduct(req, res, next) {
  const id = parseId(req.params.id);
  if (!id) return res.status(400).json({ error: "Mã sản phẩm không hợp lệ" });
  try {
    if (!(await adminModel.archiveProduct(id))) {
      return res.status(404).json({ error: "Không tìm thấy sản phẩm đang hoạt động" });
    }
    res.json({ data: { id, isActive: false } });
  } catch (error) {
    next(error);
  }
}

async function restoreProduct(req, res, next) {
  const id = parseId(req.params.id);
  if (!id) return res.status(400).json({ error: "Mã sản phẩm không hợp lệ" });
  try {
    if (!(await adminModel.restoreProduct(id))) {
      return res.status(404).json({ error: "Không tìm thấy sản phẩm đã ẩn" });
    }
    res.json({ data: { id, isActive: true } });
  } catch (error) {
    next(error);
  }
}

async function listUsers(_req, res, next) {
  try {
    res.json({ data: await adminModel.listUsers() });
  } catch (error) {
    next(error);
  }
}

async function updateUser(req, res, next) {
  const id = parseId(req.params.id);
  if (!id) return res.status(400).json({ error: "Mã tài khoản không hợp lệ" });
  const { role, isActive } = req.body || {};
  const isSuperAdmin = req.user.role === "super_admin";
  if (role !== undefined && (!isSuperAdmin || !["customer", "admin"].includes(role))) {
    return res.status(403).json({ error: "Không đủ quyền thay đổi vai trò này" });
  }
  if (isActive !== undefined && typeof isActive !== "boolean") {
    return res.status(400).json({ error: "Trạng thái tài khoản không hợp lệ" });
  }
  if (role === undefined && isActive === undefined) {
    return res.status(400).json({ error: "Không có thông tin cần cập nhật" });
  }
  if (String(req.user.sub) === String(id) && isActive === false) {
    return res.status(400).json({ error: "Bạn không thể tự vô hiệu hóa tài khoản đang sử dụng" });
  }
  try {
    const existingUsers = await adminModel.listUsers();
    const target = existingUsers.find((user) => String(user.id) === String(id));
    if (!target) return res.status(404).json({ error: "Không tìm thấy tài khoản" });
    if (target.role === "super_admin") {
      return res.status(403).json({ error: "Không thể thay đổi tài khoản quản trị viên tổng" });
    }
    if (!isSuperAdmin && target.role !== "customer") {
      return res.status(403).json({ error: "Chỉ quản trị viên tổng mới được quản lý quản trị viên khác" });
    }
    const user = await adminModel.updateUser(id, {
      role: isSuperAdmin ? role ?? null : null,
      isActive: isActive ?? null,
      actorRole: req.user.role,
    });
    if (!user) return res.status(409).json({ error: "Vai trò tài khoản đã thay đổi. Vui lòng tải lại danh sách." });
    res.json({ data: user });
  } catch (error) {
    next(error);
  }
}

async function listOrders(_req, res, next) {
  try {
    res.json({ data: await adminModel.listOrders() });
  } catch (error) {
    next(error);
  }
}

async function updateOrderStatus(req, res, next) {
  const id = parseId(req.params.id);
  const { status } = req.body || {};
  if (!id) return res.status(400).json({ error: "Mã đơn hàng không hợp lệ" });
  if (!ORDER_STATUSES.includes(status)) {
    return res.status(400).json({ error: "Trạng thái đơn hàng không hợp lệ" });
  }
  try {
    const result = await adminModel.changeOrderStatus(id, status);
    if (result.kind === "not_found") return res.status(404).json({ error: "Không tìm thấy đơn hàng" });
    if (result.kind === "invalid_transition") {
      return res.status(409).json({
        error: `Không thể chuyển đơn từ trạng thái ${result.currentStatus} sang ${status}`,
      });
    }
    res.json({ data: { id, status } });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  overview,
  listProducts,
  catalogOptions,
  createProduct,
  updateProduct,
  archiveProduct,
  restoreProduct,
  listUsers,
  updateUser,
  listOrders,
  updateOrderStatus,
};
