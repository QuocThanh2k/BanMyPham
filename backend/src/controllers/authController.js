const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const customerModel = require("../models/khachHangModel");

function createBackendToken(customer) {
  if (!process.env.JWT_SECRET) {
    const error = new Error("Máy chủ chưa được cấu hình JWT_SECRET");
    error.status = 500;
    throw error;
  }
  return jwt.sign(
    { sub: String(customer.id), role: customer.role },
    process.env.JWT_SECRET,
    { expiresIn: "12h" },
  );
}

async function login(req, res, next) {
  try {
    const email = typeof req.body.email === "string" ? req.body.email.trim().toLowerCase() : "";
    const password = typeof req.body.password === "string" ? req.body.password : "";
    if (!email || !password || email.length > 255 || password.length > 128) {
      return res.status(400).json({ error: "Email hoặc mật khẩu không hợp lệ" });
    }
    const customer = await customerModel.findByEmail(email);
    if (!customer) return res.status(401).json({ error: "Email hoặc mật khẩu không chính xác" });
    if (!customer.isActive) {
      return res.status(403).json({ error: "Tài khoản đã bị vô hiệu hóa" });
    }
    if (customer.mustResetPassword) {
      return res.status(403).json({ error: "Tài khoản cần được đặt lại mật khẩu trước khi đăng nhập" });
    }
    if (!(await bcrypt.compare(password, customer.passwordHash))) {
      return res.status(401).json({ error: "Email hoặc mật khẩu không chính xác" });
    }
    const token = createBackendToken(customer);
    res.json({
      token,
      user: {
        id: String(customer.id),
        name: customer.fullName,
        email: customer.email,
        phone: customer.phone,
        address: customer.address,
        role: customer.role,
        isActive: customer.isActive,
        mustResetPassword: customer.mustResetPassword,
        createdAt: customer.createdAt,
      },
    });
  } catch (error) {
    next(error);
  }
}

async function register(req, res, next) {
  try {
    if (!process.env.JWT_SECRET) {
      return res.status(500).json({ error: "Máy chủ chưa được cấu hình JWT_SECRET" });
    }
    const fullName = typeof req.body.fullName === "string" ? req.body.fullName.trim() : "";
    const email = typeof req.body.email === "string" ? req.body.email.trim().toLowerCase() : "";
    const password = typeof req.body.password === "string" ? req.body.password : "";
    const phone = typeof req.body.phone === "string" ? req.body.phone.trim() : "";
    if (email === "quocthanh2614@gmail.com") {
      return res.status(403).json({
        error: "Email quản trị viên tổng được bảo lưu. Vui lòng sử dụng tài khoản đã được thiết lập.",
      });
    }

    if (!fullName || fullName.length > 150 ||
        !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) || email.length > 255 ||
        password.length < 8 || password.length > 128 ||
        phone.length > 20) {
      return res.status(400).json({
        error: "Vui lòng nhập họ tên, email hợp lệ và mật khẩu từ 8 đến 128 ký tự.",
      });
    }
    if (await customerModel.findByEmail(email)) {
      return res.status(409).json({ error: "Email này đã được đăng ký." });
    }

    const passwordHash = await bcrypt.hash(password, 12);
    let customer;
    try {
      customer = await customerModel.create({
        fullName,
        email,
        passwordHash,
        phone,
        address: "",
      });
    } catch (error) {
      if (error.number === 2601 || error.number === 2627) {
        return res.status(409).json({ error: "Email này đã được đăng ký." });
      }
      throw error;
    }

    const token = createBackendToken({ ...customer, role: "customer" });
    res.status(201).json({
      token,
      user: {
        id: String(customer.id),
        name: customer.fullName,
        email: customer.email,
        phone: customer.phone,
        address: customer.address,
        role: customer.role,
        isActive: customer.isActive,
        mustResetPassword: customer.mustResetPassword,
        createdAt: customer.createdAt,
      },
    });
  } catch (error) {
    next(error);
  }
}

function currentUser(req, res) {
  res.json({ data: { id: req.user.sub, role: req.user.role } });
}

module.exports = { login, register, currentUser };
