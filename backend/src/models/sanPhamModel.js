const { sql, connectDB } = require("../config/database");

async function findAll({ categoryId, categorySlug, brandSlug, search, limit = 24, offset = 0 } = {}) {
  const conditions = ["sp.TrangThai = 1"];
  const pool = await connectDB();
  const request = pool.request();
  if (categoryId !== undefined) {
    conditions.push("sp.MaDanhMuc = @categoryId");
    request.input("categoryId", sql.BigInt, categoryId);
  }
  if (categorySlug !== undefined) {
    conditions.push("dm.Slug = @categorySlug");
    request.input("categorySlug", sql.NVarChar(180), categorySlug);
  }
  if (brandSlug !== undefined) {
    conditions.push("th.Slug = @brandSlug");
    request.input("brandSlug", sql.NVarChar(180), brandSlug);
  }
  if (search !== undefined) {
    conditions.push("(sp.TenSanPham LIKE @search OR sp.Slug LIKE @search OR th.TenThuongHieu LIKE @search)");
    request.input("search", sql.NVarChar(180), `%${search}%`);
  }
  request.input("limit", sql.Int, limit);
  request.input("offset", sql.Int, offset);
  const where = `WHERE ${conditions.join(" AND ")}`;
  const { recordset } = await request.query(
    `SELECT sp.MaSanPham AS id, sp.Slug AS slug, sp.TenSanPham AS name,
      sp.Gia AS price, sp.GiaGoc AS originalPrice, sp.SoLuongKho AS stock,
      sp.LinkAnh AS imageUrl, sp.MaDanhMuc AS categoryId, sp.MaThuongHieu AS brandId,
      sp.MoTa AS description, ld.Slug AS skinType, sp.DanhGia AS rating,
      sp.HanSuDung AS expiresAt
     FROM SanPham sp
     LEFT JOIN DanhMuc dm ON dm.MaDanhMuc = sp.MaDanhMuc
     LEFT JOIN ThuongHieu th ON th.MaThuongHieu = sp.MaThuongHieu
     LEFT JOIN LoaiDa ld ON ld.MaLoaiDa = sp.MaLoaiDa
     ${where} ORDER BY sp.MaSanPham DESC
     OFFSET @offset ROWS FETCH NEXT @limit ROWS ONLY`,
  );
  return recordset;
}

async function findById(id) {
  const pool = await connectDB();
  const { recordset } = await pool.request()
    .input("id", sql.BigInt, id)
    .query(
      `SELECT sp.MaSanPham AS id, sp.Slug AS slug, sp.TenSanPham AS name,
        sp.Gia AS price, sp.GiaGoc AS originalPrice, sp.SoLuongKho AS stock,
        sp.LinkAnh AS imageUrl, sp.MaDanhMuc AS categoryId, sp.MaThuongHieu AS brandId,
        sp.MoTa AS description, ld.Slug AS skinType, sp.DanhGia AS rating, sp.NgayNhapHang AS receivedAt,
        sp.HanSuDung AS expiresAt
       FROM SanPham sp
       LEFT JOIN DanhMuc dm ON dm.MaDanhMuc = sp.MaDanhMuc
       LEFT JOIN ThuongHieu th ON th.MaThuongHieu = sp.MaThuongHieu
       LEFT JOIN LoaiDa ld ON ld.MaLoaiDa = sp.MaLoaiDa
       WHERE sp.MaSanPham = @id AND sp.TrangThai = 1`,
    );
  return recordset[0] || null;
}

async function findBySlug(slug) {
  const pool = await connectDB();
  const { recordset } = await pool.request()
    .input("slug", sql.NVarChar(180), slug)
    .query(
      `SELECT sp.MaSanPham AS id, sp.Slug AS slug, sp.TenSanPham AS name,
        sp.Gia AS price, sp.GiaGoc AS originalPrice, sp.SoLuongKho AS stock,
        sp.LinkAnh AS imageUrl, sp.MaDanhMuc AS categoryId, sp.MaThuongHieu AS brandId,
        sp.MoTa AS description, ld.Slug AS skinType, sp.DanhGia AS rating,
        sp.NgayNhapHang AS receivedAt, sp.HanSuDung AS expiresAt
       FROM SanPham sp
       LEFT JOIN DanhMuc dm ON dm.MaDanhMuc = sp.MaDanhMuc
       LEFT JOIN ThuongHieu th ON th.MaThuongHieu = sp.MaThuongHieu
       LEFT JOIN LoaiDa ld ON ld.MaLoaiDa = sp.MaLoaiDa
       WHERE sp.Slug = @slug AND sp.TrangThai = 1`,
    );
  return recordset[0] || null;
}

module.exports = { findAll, findById, findBySlug };
