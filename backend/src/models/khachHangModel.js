const { sql, connectDB } = require("../config/database");

async function findByEmail(email) {
  const pool = await connectDB();
  const { recordset } = await pool.request()
    .input("email", sql.NVarChar(255), email)
    .query(
      `SELECT MaKhachHang AS id, HoTen AS fullName, Email AS email, MatKhau AS passwordHash,
        SoDienThoai AS phone, DiaChi AS address,
        CASE WHEN LOWER(Email) = N'quocthanh2614@gmail.com' THEN N'super_admin' ELSE VaiTro END AS role,
        TaiKhoanHoatDong AS isActive, CanDatLaiMatKhau AS mustResetPassword,
        NgayTao AS createdAt
       FROM KhachHang WHERE Email = @email`,
    );
  return recordset[0] || null;
}

async function findById(id) {
  const pool = await connectDB();
  const { recordset } = await pool.request()
    .input("id", sql.BigInt, id)
    .query(
      `SELECT MaKhachHang AS id,
         CASE WHEN LOWER(Email) = N'quocthanh2614@gmail.com' THEN N'super_admin' ELSE VaiTro END AS role,
         TaiKhoanHoatDong AS isActive
       FROM KhachHang WHERE MaKhachHang = @id`,
    );
  return recordset[0] || null;
}

async function create({ fullName, email, passwordHash, phone, address }) {
  const pool = await connectDB();
  const { recordset } = await pool.request()
    .input("fullName", sql.NVarChar(150), fullName)
    .input("email", sql.NVarChar(255), email)
    .input("passwordHash", sql.NVarChar(255), passwordHash)
    .input("phone", sql.NVarChar(20), phone || null)
    .input("address", sql.NVarChar(sql.MAX), address || null)
    .query(
      `INSERT INTO KhachHang (HoTen, Email, MatKhau, SoDienThoai, DiaChi)
       OUTPUT INSERTED.MaKhachHang AS id, INSERTED.HoTen AS fullName,
         INSERTED.Email AS email, INSERTED.SoDienThoai AS phone,
         INSERTED.DiaChi AS address, INSERTED.VaiTro AS role,
         INSERTED.TaiKhoanHoatDong AS isActive,
         INSERTED.CanDatLaiMatKhau AS mustResetPassword,
         INSERTED.NgayTao AS createdAt
       VALUES (@fullName, @email, @passwordHash, @phone, @address)`,
    );
  return recordset[0];
}

module.exports = { findByEmail, findById, create };
