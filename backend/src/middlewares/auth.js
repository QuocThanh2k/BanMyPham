const jwt = require("jsonwebtoken");
const customerModel = require("../models/khachHangModel");

async function requireAuth(req, res, next) {
  const authorization = req.headers.authorization;
  const token = authorization?.startsWith("Bearer ") ? authorization.slice(7) : null;
  if (!token) return res.status(401).json({ error: "Yêu cầu đăng nhập" });
  try {
    const tokenUser = jwt.verify(token, process.env.JWT_SECRET);
    const user = await customerModel.findById(tokenUser.sub);
    if (!user || !user.isActive) {
      return res.status(401).json({ error: "Tài khoản không tồn tại hoặc đã bị vô hiệu hóa" });
    }
    req.user = { sub: String(user.id), role: user.role };
    return next();
  } catch (error) {
    if (error.name === "JsonWebTokenError" || error.name === "TokenExpiredError") {
      return res.status(401).json({ error: "Token không hợp lệ hoặc đã hết hạn" });
    }
    return next(error);
  }
}

function requireAdmin(req, res, next) {
  if (!["admin", "super_admin"].includes(req.user?.role)) {
    return res.status(403).json({ error: "Không đủ quyền truy cập" });
  }
  next();
}

function requireSuperAdmin(req, res, next) {
  if (req.user?.role !== "super_admin") {
    return res.status(403).json({ error: "Chỉ quản trị viên tổng mới có quyền này" });
  }
  next();
}

module.exports = { requireAuth, requireAdmin, requireSuperAdmin };
