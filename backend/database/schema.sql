-- SQL Server schema and Firebase seed data for ThanhtamCosmetics.
-- Run this script in SQL Server Management Studio or sqlcmd.
-- Existing SQL Server databases must apply the numbered migrations first.
-- Imported account passwords are not stored in plaintext; accounts require a password reset.
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;

IF DB_ID(N'ThanhtamCosmetics') IS NULL
    EXEC(N'CREATE DATABASE [ThanhtamCosmetics]');
GO
USE [ThanhtamCosmetics];
GO


IF OBJECT_ID(N'dbo.KhachHang', N'U') IS NULL
BEGIN
CREATE TABLE dbo.KhachHang (
  MaKhachHang BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  FirebaseId NVARCHAR(64),
  HoTen NVARCHAR(150) NOT NULL,
  Email NVARCHAR(255) NOT NULL UNIQUE,
  MatKhau NVARCHAR(255) NOT NULL,
  SoDienThoai NVARCHAR(20),
  DiaChi NVARCHAR(MAX),
  VaiTro NVARCHAR(20) NOT NULL DEFAULT N'customer' CHECK (VaiTro IN (N'customer', N'admin', N'super_admin')),
  TaiKhoanHoatDong BIT NOT NULL DEFAULT 1,
  CanDatLaiMatKhau BIT NOT NULL DEFAULT 0,
  NgayTao DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME()
);
END;

IF EXISTS (
  SELECT 1
  FROM sys.key_constraints kc
  INNER JOIN sys.index_columns ic
    ON ic.object_id = kc.parent_object_id
    AND ic.index_id = kc.unique_index_id
    AND ic.key_ordinal = 1
  WHERE kc.parent_object_id = OBJECT_ID(N'dbo.KhachHang')
    AND kc.type = N'UQ'
    AND ic.column_id = COLUMNPROPERTY(OBJECT_ID(N'dbo.KhachHang'), N'FirebaseId', 'ColumnId')
    AND NOT EXISTS (
      SELECT 1
      FROM sys.index_columns extra
      WHERE extra.object_id = kc.parent_object_id
        AND extra.index_id = kc.unique_index_id
        AND extra.key_ordinal > 1
    )
)
BEGIN
  DECLARE @firebaseConstraint sysname;
  DECLARE @dropFirebaseConstraintSql nvarchar(max);
  SELECT TOP (1) @firebaseConstraint = kc.name
  FROM sys.key_constraints kc
  INNER JOIN sys.index_columns ic
    ON ic.object_id = kc.parent_object_id
    AND ic.index_id = kc.unique_index_id
    AND ic.key_ordinal = 1
  WHERE kc.parent_object_id = OBJECT_ID(N'dbo.KhachHang')
    AND kc.type = N'UQ'
    AND ic.column_id = COLUMNPROPERTY(OBJECT_ID(N'dbo.KhachHang'), N'FirebaseId', 'ColumnId')
    AND NOT EXISTS (
      SELECT 1
      FROM sys.index_columns extra
      WHERE extra.object_id = kc.parent_object_id
        AND extra.index_id = kc.unique_index_id
        AND extra.key_ordinal > 1
    );
  SET @dropFirebaseConstraintSql = N'ALTER TABLE dbo.KhachHang DROP CONSTRAINT ' + QUOTENAME(@firebaseConstraint);
  EXEC sys.sp_executesql @dropFirebaseConstraintSql;
END;

IF EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE object_id = OBJECT_ID(N'dbo.KhachHang')
    AND name = N'uq_khachhang_firebase_id'
    AND is_unique = 1
    AND has_filter = 0
)
  DROP INDEX uq_khachhang_firebase_id ON dbo.KhachHang;

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE object_id = OBJECT_ID(N'dbo.KhachHang')
    AND name = N'uq_khachhang_firebase_id'
)
  CREATE UNIQUE INDEX uq_khachhang_firebase_id
    ON dbo.KhachHang(FirebaseId)
    WHERE FirebaseId IS NOT NULL;

IF OBJECT_ID(N'dbo.ThongTinUngDung', N'U') IS NULL
BEGIN
CREATE TABLE dbo.ThongTinUngDung (
  Khoa NVARCHAR(100) NOT NULL PRIMARY KEY,
  GiaTri NVARCHAR(MAX) NOT NULL
);
END;

IF OBJECT_ID(N'dbo.DanhMuc', N'U') IS NULL
BEGIN
CREATE TABLE dbo.DanhMuc (
  MaDanhMuc BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  FirebaseId NVARCHAR(64) UNIQUE,
  TenDanhMuc NVARCHAR(150) NOT NULL,
  Slug NVARCHAR(180) NOT NULL UNIQUE,
  Icon NVARCHAR(80),
  SoLuongSanPham INT NOT NULL DEFAULT 0,
  TrangThai BIT NOT NULL DEFAULT 1
);
END;

IF OBJECT_ID(N'dbo.ThuongHieu', N'U') IS NULL
BEGIN
CREATE TABLE dbo.ThuongHieu (
  MaThuongHieu BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  FirebaseId NVARCHAR(64) UNIQUE,
  TenThuongHieu NVARCHAR(150) NOT NULL,
  Slug NVARCHAR(180) NOT NULL UNIQUE,
  SoLuongSanPham INT NOT NULL DEFAULT 0,
  TrangThai BIT NOT NULL DEFAULT 1
);
END;

IF OBJECT_ID(N'dbo.LoaiDa', N'U') IS NULL
BEGIN
CREATE TABLE dbo.LoaiDa (
  MaLoaiDa BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  FirebaseId NVARCHAR(64) UNIQUE,
  TenLoaiDa NVARCHAR(100) NOT NULL,
  Slug NVARCHAR(80) NOT NULL UNIQUE,
  TrangThai BIT NOT NULL DEFAULT 1
);
END;

IF OBJECT_ID(N'dbo.SanPham', N'U') IS NULL
BEGIN
CREATE TABLE dbo.SanPham (
  MaSanPham BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  FirebaseId NVARCHAR(64) UNIQUE,
  TenSanPham NVARCHAR(255) NOT NULL,
  Slug NVARCHAR(255) NOT NULL UNIQUE,
  MoTa NVARCHAR(MAX),
  Gia DECIMAL(12, 2) NOT NULL,
  GiaGoc DECIMAL(12, 2),
  SoLuongKho INT NOT NULL DEFAULT 0,
  LinkAnh NVARCHAR(2048),
  MaDanhMuc BIGINT,
  MaThuongHieu BIGINT,
  MaLoaiDa BIGINT,
  DanhGia DECIMAL(2, 1),
  TrangThai BIT NOT NULL DEFAULT 1,
  NgayNhapHang DATE,
  HanSuDung DATE,
  NgayTao DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
  CONSTRAINT fk_sanpham_danhmuc FOREIGN KEY (MaDanhMuc) REFERENCES dbo.DanhMuc(MaDanhMuc) ON DELETE SET NULL,
  CONSTRAINT fk_sanpham_thuonghieu FOREIGN KEY (MaThuongHieu) REFERENCES dbo.ThuongHieu(MaThuongHieu) ON DELETE SET NULL,
  CONSTRAINT fk_sanpham_loaida FOREIGN KEY (MaLoaiDa) REFERENCES dbo.LoaiDa(MaLoaiDa) ON DELETE SET NULL,
  CONSTRAINT chk_sanpham_gia CHECK (Gia >= 0 AND (GiaGoc IS NULL OR GiaGoc >= 0))
);
END;

IF OBJECT_ID(N'dbo.MaGiamGia', N'U') IS NULL
BEGIN
CREATE TABLE dbo.MaGiamGia (
  MaCode NVARCHAR(50) NOT NULL PRIMARY KEY,
  TenMa NVARCHAR(150) NOT NULL,
  LoaiGiamGia NVARCHAR(10) NOT NULL CHECK (LoaiGiamGia IN (N'percent', N'fixed')),
  GiaTri DECIMAL(12, 2) NOT NULL,
  NgayBatDau DATETIME2(0),
  NgayKetThuc DATETIME2(0),
  SoLuong INT,
  TrangThai BIT NOT NULL DEFAULT 1
);
END;

IF OBJECT_ID(N'dbo.DonHang', N'U') IS NULL
BEGIN
CREATE TABLE dbo.DonHang (
  MaDonHang BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  MaKhachHang BIGINT,
  TrangThai NVARCHAR(20) NOT NULL DEFAULT N'pending' CHECK (TrangThai IN (N'pending', N'confirmed', N'shipped', N'completed', N'cancelled')),
  MaGiamGiaCode NVARCHAR(50),
  TongTienHang DECIMAL(12, 2) NOT NULL,
  PhiVanChuyen DECIMAL(12, 2) NOT NULL DEFAULT 0,
  TongThanhToan DECIMAL(12, 2) NOT NULL,
  PhuongThucThanhToan NVARCHAR(10) NOT NULL CHECK (PhuongThucThanhToan IN (N'cod', N'stripe')),
  NgayDat DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
  CONSTRAINT fk_donhang_khachhang FOREIGN KEY (MaKhachHang) REFERENCES dbo.KhachHang(MaKhachHang) ON DELETE SET NULL,
  CONSTRAINT fk_donhang_magiamgia FOREIGN KEY (MaGiamGiaCode) REFERENCES dbo.MaGiamGia(MaCode) ON DELETE SET NULL
);
END;

IF OBJECT_ID(N'dbo.ChiTietDonHang', N'U') IS NULL
BEGIN
CREATE TABLE dbo.ChiTietDonHang (
  MaChiTiet BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
  MaDonHang BIGINT NOT NULL,
  MaSanPham BIGINT NOT NULL,
  SoLuong INT NOT NULL,
  GiaDonVi DECIMAL(12, 2) NOT NULL,
  GiamGia DECIMAL(12, 2) NOT NULL DEFAULT 0,
  CONSTRAINT fk_chitiet_donhang FOREIGN KEY (MaDonHang) REFERENCES dbo.DonHang(MaDonHang) ON DELETE CASCADE,
  CONSTRAINT fk_chitiet_sanpham FOREIGN KEY (MaSanPham) REFERENCES dbo.SanPham(MaSanPham),
  CONSTRAINT chk_chitiet_soluong CHECK (SoLuong > 0)
);
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_sanpham_danhmuc' AND object_id = OBJECT_ID(N'dbo.SanPham')) CREATE INDEX idx_sanpham_danhmuc ON dbo.SanPham(MaDanhMuc);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_sanpham_hansudung' AND object_id = OBJECT_ID(N'dbo.SanPham')) CREATE INDEX idx_sanpham_hansudung ON dbo.SanPham(HanSuDung);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_donhang_khachhang_ngay' AND object_id = OBJECT_ID(N'dbo.DonHang')) CREATE INDEX idx_donhang_khachhang_ngay ON dbo.DonHang(MaKhachHang, NgayDat);

-- BEGIN FIREBASE DATA SEED
SET XACT_ABORT ON;
BEGIN TRANSACTION;

IF NOT EXISTS (SELECT 1 FROM dbo.ThongTinUngDung WHERE Khoa = N'name')
BEGIN
INSERT INTO dbo.ThongTinUngDung (Khoa, GiaTri) VALUES (N'name', N'Thanh Tâm Cosmetics - Firebase Database');
END;
IF NOT EXISTS (SELECT 1 FROM dbo.ThongTinUngDung WHERE Khoa = N'version')
BEGIN
INSERT INTO dbo.ThongTinUngDung (Khoa, GiaTri) VALUES (N'version', N'2.0.0');
END;
IF NOT EXISTS (SELECT 1 FROM dbo.ThongTinUngDung WHERE Khoa = N'firebase_type')
BEGIN
INSERT INTO dbo.ThongTinUngDung (Khoa, GiaTri) VALUES (N'firebase_type', N'realtime-database');
END;
IF NOT EXISTS (SELECT 1 FROM dbo.ThongTinUngDung WHERE Khoa = N'description')
BEGIN
INSERT INTO dbo.ThongTinUngDung (Khoa, GiaTri) VALUES (N'description', N'Cơ sở dữ liệu hoàn chỉnh cho website mỹ phẩm Thanh Tâm - 300 sản phẩm');
END;
IF NOT EXISTS (SELECT 1 FROM dbo.ThongTinUngDung WHERE Khoa = N'total_products')
BEGIN
INSERT INTO dbo.ThongTinUngDung (Khoa, GiaTri) VALUES (N'total_products', N'300');
END;


IF NOT EXISTS (SELECT 1 FROM dbo.DanhMuc WHERE FirebaseId = N'cat_001')
BEGIN
INSERT INTO dbo.DanhMuc (FirebaseId, TenDanhMuc, Slug, Icon, SoLuongSanPham, TrangThai) VALUES (N'cat_001', N'Chăm sóc da', N'skincare', N'fa-spa', 150, 1);
END;
IF NOT EXISTS (SELECT 1 FROM dbo.DanhMuc WHERE FirebaseId = N'cat_002')
BEGIN
INSERT INTO dbo.DanhMuc (FirebaseId, TenDanhMuc, Slug, Icon, SoLuongSanPham, TrangThai) VALUES (N'cat_002', N'Trang điểm', N'makeup', N'fa-paint-brush', 60, 1);
END;
IF NOT EXISTS (SELECT 1 FROM dbo.DanhMuc WHERE FirebaseId = N'cat_003')
BEGIN
INSERT INTO dbo.DanhMuc (FirebaseId, TenDanhMuc, Slug, Icon, SoLuongSanPham, TrangThai) VALUES (N'cat_003', N'Làm sạch', N'cleansing', N'fa-hands-wash', 40, 1);
END;
IF NOT EXISTS (SELECT 1 FROM dbo.DanhMuc WHERE FirebaseId = N'cat_004')
BEGIN
INSERT INTO dbo.DanhMuc (FirebaseId, TenDanhMuc, Slug, Icon, SoLuongSanPham, TrangThai) VALUES (N'cat_004', N'Nước hoa', N'perfume', N'fa-wind', 25, 1);
END;
IF NOT EXISTS (SELECT 1 FROM dbo.DanhMuc WHERE FirebaseId = N'cat_005')
BEGIN
INSERT INTO dbo.DanhMuc (FirebaseId, TenDanhMuc, Slug, Icon, SoLuongSanPham, TrangThai) VALUES (N'cat_005', N'Chăm sóc tóc', N'haircare', N'fa-hair', 25, 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.ThuongHieu WHERE FirebaseId = N'brand_001')
BEGIN
INSERT INTO dbo.ThuongHieu (FirebaseId, TenThuongHieu, Slug, SoLuongSanPham, TrangThai) VALUES (N'brand_001', N'Laneige', N'laneige', 30, 1);
END;
IF NOT EXISTS (SELECT 1 FROM dbo.ThuongHieu WHERE FirebaseId = N'brand_002')
BEGIN
INSERT INTO dbo.ThuongHieu (FirebaseId, TenThuongHieu, Slug, SoLuongSanPham, TrangThai) VALUES (N'brand_002', N'Innisfree', N'innisfree', 30, 1);
END;
IF NOT EXISTS (SELECT 1 FROM dbo.ThuongHieu WHERE FirebaseId = N'brand_003')
BEGIN
INSERT INTO dbo.ThuongHieu (FirebaseId, TenThuongHieu, Slug, SoLuongSanPham, TrangThai) VALUES (N'brand_003', N'MAC', N'mac', 30, 1);
END;
IF NOT EXISTS (SELECT 1 FROM dbo.ThuongHieu WHERE FirebaseId = N'brand_004')
BEGIN
INSERT INTO dbo.ThuongHieu (FirebaseId, TenThuongHieu, Slug, SoLuongSanPham, TrangThai) VALUES (N'brand_004', N'Dior', N'dior', 30, 1);
END;
IF NOT EXISTS (SELECT 1 FROM dbo.ThuongHieu WHERE FirebaseId = N'brand_005')
BEGIN
INSERT INTO dbo.ThuongHieu (FirebaseId, TenThuongHieu, Slug, SoLuongSanPham, TrangThai) VALUES (N'brand_005', N'The Ordinary', N'theordinary', 30, 1);
END;
IF NOT EXISTS (SELECT 1 FROM dbo.ThuongHieu WHERE FirebaseId = N'brand_006')
BEGIN
INSERT INTO dbo.ThuongHieu (FirebaseId, TenThuongHieu, Slug, SoLuongSanPham, TrangThai) VALUES (N'brand_006', N'La Roche-Posay', N'larocheposay', 30, 1);
END;
IF NOT EXISTS (SELECT 1 FROM dbo.ThuongHieu WHERE FirebaseId = N'brand_007')
BEGIN
INSERT INTO dbo.ThuongHieu (FirebaseId, TenThuongHieu, Slug, SoLuongSanPham, TrangThai) VALUES (N'brand_007', N'Cocoon', N'cocoon', 30, 1);
END;
IF NOT EXISTS (SELECT 1 FROM dbo.ThuongHieu WHERE FirebaseId = N'brand_008')
BEGIN
INSERT INTO dbo.ThuongHieu (FirebaseId, TenThuongHieu, Slug, SoLuongSanPham, TrangThai) VALUES (N'brand_008', N'Garnier', N'garnier', 30, 1);
END;
IF NOT EXISTS (SELECT 1 FROM dbo.ThuongHieu WHERE FirebaseId = N'brand_009')
BEGIN
INSERT INTO dbo.ThuongHieu (FirebaseId, TenThuongHieu, Slug, SoLuongSanPham, TrangThai) VALUES (N'brand_009', N'Yves Saint Laurent', N'ysl', 30, 1);
END;
IF NOT EXISTS (SELECT 1 FROM dbo.ThuongHieu WHERE FirebaseId = N'brand_010')
BEGIN
INSERT INTO dbo.ThuongHieu (FirebaseId, TenThuongHieu, Slug, SoLuongSanPham, TrangThai) VALUES (N'brand_010', N'Chanel', N'chanel', 30, 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.LoaiDa WHERE FirebaseId = N'skin_001')
BEGIN
INSERT INTO dbo.LoaiDa (FirebaseId, TenLoaiDa, Slug, TrangThai) VALUES (N'skin_001', N'Da dầu', N'da-dau', 1);
END;
IF NOT EXISTS (SELECT 1 FROM dbo.LoaiDa WHERE FirebaseId = N'skin_002')
BEGIN
INSERT INTO dbo.LoaiDa (FirebaseId, TenLoaiDa, Slug, TrangThai) VALUES (N'skin_002', N'Da khô', N'da-kho', 1);
END;
IF NOT EXISTS (SELECT 1 FROM dbo.LoaiDa WHERE FirebaseId = N'skin_003')
BEGIN
INSERT INTO dbo.LoaiDa (FirebaseId, TenLoaiDa, Slug, TrangThai) VALUES (N'skin_003', N'Da hỗn hợp', N'da-hon-hop', 1);
END;
IF NOT EXISTS (SELECT 1 FROM dbo.LoaiDa WHERE FirebaseId = N'skin_004')
BEGIN
INSERT INTO dbo.LoaiDa (FirebaseId, TenLoaiDa, Slug, TrangThai) VALUES (N'skin_004', N'Da nhạy cảm', N'da-nhay-cam', 1);
END;
IF NOT EXISTS (SELECT 1 FROM dbo.LoaiDa WHERE Slug = N'M?i lo?i da')
BEGIN
INSERT INTO dbo.LoaiDa (FirebaseId, TenLoaiDa, Slug, TrangThai) VALUES (NULL, N'M?i lo?i da', N'all', 1);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_L001')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_L001', N'Kem Dưỡng Ẩm Water Bank', N'laneige-water-bank', N'Kem dưỡng ẩm cấp nước cho da', 385000, 450000, 50, N'images/SP/L001.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'laneige'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_L002')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_L002', N'Sleeping Mask 2X', N'laneige-sleeping-mask-2x', N'Mặt nạ ngủ cấp ẩm gấp đôi', 420000, NULL, 45, N'images/SP/L002.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'laneige'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_L003')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_L003', N'Lip Sleeping Mask', N'laneige-lip-mask', N'Mặt nạ ngủ dưỡng môi', 265000, 320000, 80, N'images/SP/L003.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'laneige'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_L004')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_L004', N'Toner Pore Tightening', N'laneige-toner-pore', N'Nước hoa hồng se khít lỗ chân lông', 195000, NULL, 70, N'images/SP/L004.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'laneige'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.5, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_L005')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_L005', N'Essence Emulsion', N'laneige-essence-emulsion', N'Tinh chất dưỡng ẩm emulsion', 355000, NULL, 55, N'images/SP/L005.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'laneige'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-hon-hop'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_L006')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_L006', N'Cream Skin Refiner', N'laneige-cream-skin', N'Nước dưỡng da dạng cream', 425000, 500000, 40, N'images/SP/L006.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'laneige'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_L007')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_L007', N'Eye Cream', N'laneige-eye-cream', N'Kem dưỡng mắt giảm quầng thâm', 485000, NULL, 35, N'images/SP/L007.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'laneige'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_L008')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_L008', N'Cleansing Foam', N'laneige-cleansing-foam', N'Sữa rửa mặt tạo bọt mịn', 165000, NULL, 90, N'images/SP/L008.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'laneige'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.5, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_L009')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_L009', N'Oil Cleansing', N'laneige-oil-cleansing', N'Dầu tẩy trang làm sạch sâu', 225000, 280000, 65, N'images/SP/L009.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'laneige'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_L010')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_L010', N'Water Drop Cream', N'laneige-water-drop', N'Kem dưỡng thấm nhanh như nước', 395000, NULL, 50, N'images/SP/L010.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'laneige'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_L011')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_L011', N'Mineral Eye Palette', N'laneige-eye-palette', N'Bảng phấn mắt khoáng', 485000, NULL, 40, N'images/SP/L011.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'laneige'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_L012')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_L012', N'Lip Glow', N'laneige-lip-glow', N'Son dưỡng môi có màu', 285000, NULL, 75, N'images/SP/L012.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'laneige'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_L013')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_L013', N'Cushion SPF50', N'laneige-cushion-spf50', N'Cushion chống nắng SPF50', 455000, 520000, 45, N'images/SP/L013.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'laneige'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_L014')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_L014', N'Serum Vitamin C', N'laneige-serum-vitc', N'Serum Vitamin C làm sáng da', 585000, NULL, 35, N'images/SP/L014.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'laneige'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_L015')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_L015', N'Firming Cream', N'laneige-firming-cream', N'Kem dưỡng làm săn chắc da', 625000, 750000, 30, N'images/SP/L015.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'laneige'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_L016')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_L016', N'Aloe Soothing Gel', N'laneige-aloe-gel', N'Gel aloe vera làm dịu da', 185000, NULL, 85, N'images/SP/L016.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'laneige'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-nhay-cam'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_L017')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_L017', N'Whitening Essence', N'laneige-whitening', N'Tinh chất trắng da', 525000, NULL, 40, N'images/SP/L017.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'laneige'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-hon-hop'), 4.5, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_L018')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_L018', N'Pore Care Serum', N'laneige-pore-serum', N'Serum thu nhỏ lỗ chân lông', 445000, 520000, 45, N'images/SP/L018.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'laneige'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_L019')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_L019', N'Hydro UV Essence', N'laneige-uv-essence', N'Kem chống nắng dạng essence', 365000, NULL, 60, N'images/SP/L019.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'laneige'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_L020')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_L020', N'Deep Care Mask', N'laneige-deep-mask', N'Mặt nạ dưỡng sâu', 245000, NULL, 70, N'images/SP/L020.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'laneige'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.5, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_L021')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_L021', N'Collagen Cream', N'laneige-collagen', N'Kem collagen dưỡng da', 685000, 820000, 25, N'images/SP/L021.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'laneige'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_L022')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_L022', N'Airy Mint Toner', N'laneige-mint-toner', N'Nước hoa hồng bạc hà mát lạnh', 205000, NULL, 75, N'images/SP/L022.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'laneige'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_L023')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_L023', N'Night Recovery Cream', N'laneige-night-cream', N'Kem phục hồi ban đêm', 545000, NULL, 35, N'images/SP/L023.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'laneige'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_L024')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_L024', N'Cica Sleeping Mask', N'laneige-cica-mask', N'Mặt nạ ngủ Cica làm dịu', 385000, 450000, 50, N'images/SP/L024.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'laneige'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-nhay-cam'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_L025')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_L025', N'Moisture Foundation', N'laneige-foundation', N'Phấn nền dưỡng ẩm', 465000, NULL, 40, N'images/SP/L025.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'laneige'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_L026')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_L026', N'Lip Stain', N'laneige-lip-stain', N'Son lâu trôi', 325000, NULL, 60, N'images/SP/L026.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'laneige'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_L027')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_L027', N'Perfect Compact', N'laneige-compact', N'Phấn phủ mịn lì', 385000, 450000, 45, N'images/SP/L027.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'laneige'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.5, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_L028')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_L028', N'Hair Mist', N'laneige-hair-mist', N'Xịt tóc dưỡng ẩm', 285000, NULL, 55, N'images/SP/L028.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'haircare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'laneige'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.4, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_L029')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_L029', N'Body Lotion', N'laneige-body-lotion', N'Sữa dưỡng thể', 325000, NULL, 50, N'images/SP/L029.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'laneige'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_L030')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_L030', N'Hand Cream', N'laneige-hand-cream', N'Kem dưỡng tay', 155000, 180000, 80, N'images/SP/L030.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'laneige'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_I001')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_I001', N'Green Tea Seed Hyaluronic', N'innisfree-green-tea-hyaluronic', N'Tinh chất trà xanh hyaluronic', 385000, 450000, 55, N'images/SP/I001.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'innisfree'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_I002')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_I002', N'Jeju Lava Seawater', N'innisfree-seawater', N'Nước biển núi lửa Jeju', 275000, NULL, 65, N'images/SP/I002.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'innisfree'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-hon-hop'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_I003')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_I003', N'Volcanic Pore Cleansing', N'innisfree-volcanic-cleansing', N'Sữa rửa mặt núi lửa', 185000, NULL, 90, N'images/SP/I003.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'innisfree'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_I004')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_I004', N'Volcanic Pore Clay Mask', N'innisfree-volcanic-mask', N'Mặt nạ đất sét núi lửa', 225000, 280000, 70, N'images/SP/I004.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'innisfree'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_I005')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_I005', N'Orchid Skin', N'innisfree-orchid-skin', N'Tinh dầu hoa lan dưỡng da', 485000, NULL, 40, N'images/SP/I005.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'innisfree'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_I006')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_I006', N'Green Tea Toner', N'innisfree-green-tea-toner', N'Nước hoa hồng trà xanh', 195000, NULL, 85, N'images/SP/I006.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'innisfree'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_I007')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_I007', N'Apple Seed Eye Cream', N'innisfree-apple-eye', N'Kem dưỡng mắt hạt táo', 425000, 500000, 45, N'images/SP/I007.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'innisfree'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_I008')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_I008', N'Soybean Energy Cream', N'innisfree-soybean-cream', N'Kem năng lượng đậu nành', 365000, NULL, 55, N'images/SP/I008.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'innisfree'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.5, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_I009')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_I009', N'Honey Propolis Cream', N'innisfree-honey-cream', N'Kem mật ong propolis', 445000, NULL, 40, N'images/SP/I009.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'innisfree'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_I010')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_I010', N'Bija Trouble Cream', N'innisfree-bija-cream', N'Kem trị mụn Bija', 285000, 350000, 60, N'images/SP/I010.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'innisfree'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_I011')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_I011', N'Aloe Revital Cream', N'innisfree-aloe-cream', N'Kem aloe vera phục hồi', 295000, NULL, 65, N'images/SP/I011.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'innisfree'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-nhay-cam'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_I012')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_I012', N'Rose Hydrating Line', N'innisfree-rose-line', N'Dưỡng ẩm hoa hồng', 355000, NULL, 50, N'images/SP/I012.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'innisfree'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_I013')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_I013', N'Blueberry Rebalancing', N'innisfree-blueberry', N'Cân bằng da với việt quất', 385000, 450000, 45, N'images/SP/I013.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'innisfree'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-hon-hop'), 4.5, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_I014')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_I014', N'Sea Grape Mask', N'innisfree-sea-grape', N'Mặt nạ rong biển', 185000, NULL, 75, N'images/SP/I014.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'innisfree'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_I015')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_I015', N'Deep Cleansing Oil', N'innisfree-cleansing-oil', N'Dầu tẩy trang sâu', 215000, NULL, 70, N'images/SP/I015.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'innisfree'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_I016')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_I016', N'Green Tea Eye Serum', N'innisfree-tea-eye', N'Tinh chất trà xanh dưỡng mắt', 365000, 420000, 40, N'images/SP/I016.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'innisfree'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_I017')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_I017', N'Vitamin Tree Cream', N'innisfree-vitamin-tree', N'Kem vitamin từ cây', 425000, NULL, 35, N'images/SP/I017.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'innisfree'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_I018')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_I018', N'Olive Lotion', N'innisfree-olive-lotion', N'Sữa dưỡng ô liu', 285000, NULL, 55, N'images/SP/I018.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'innisfree'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.5, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_I019')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_I019', N'Cucumber Fresh Cream', N'innisfree-cucumber-cream', N'Kem dưa leo mát lành', 265000, 320000, 60, N'images/SP/I019.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'innisfree'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-nhay-cam'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_I020')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_I020', N'Pomegranate Cream', N'innisfree-pomegranate', N'Kem lựu chống lão hóa', 485000, NULL, 35, N'images/SP/I020.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'innisfree'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_I021')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_I021', N'Tea Tree Serum', N'innisfree-tea-tree-serum', N'Serum tràm trà trị mụn', 345000, NULL, 50, N'images/SP/I021.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'innisfree'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_I022')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_I022', N'Rice Bran Essence', N'innisfree-rice-essence', N'Tinh chất cám gạo', 395000, 450000, 45, N'images/SP/I022.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'innisfree'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-hon-hop'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_I023')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_I023', N'Perfume Perfector', N'innisfree-perfume', N'Xịt dưỡng thơm', 255000, NULL, 40, N'images/SP/I023.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'perfume'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'innisfree'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.5, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_I024')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_I024', N'Hair Loss Care', N'innisfree-hair-care', N'Dầu gội chống rụng tóc', 185000, NULL, 65, N'images/SP/I024.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'haircare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'innisfree'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.4, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_I025')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_I025', N'Innisfree Perfume', N'innisfree-perfume-bottle', N'Nước hoa Innisfree', 1250000, 1500000, 20, N'images/SP/I025.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'perfume'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'innisfree'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_I026')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_I026', N'Capsule Foundation', N'innisfree-foundation', N'Phấn nền capsule', 425000, NULL, 45, N'images/SP/I026.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'innisfree'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_I027')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_I027', N'Blush Powder', N'innisfree-blush', N'Phấn má hồng', 265000, NULL, 55, N'images/SP/I027.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'innisfree'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.5, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_I028')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_I028', N'Lip Bar', N'innisfree-lip-bar', N'Son dưỡng môi', 185000, 220000, 80, N'images/SP/I028.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'innisfree'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_I029')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_I029', N'Cushion Limited', N'innisfree-cushion-limited', N'Cushion phiên bản giới hạn', 485000, NULL, 30, N'images/SP/I029.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'innisfree'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_I030')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_I030', N'Mint Shampoo', N'innisfree-mint-shampoo', N'Dầu gội bạc hà', 165000, NULL, 75, N'images/SP/I030.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'haircare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'innisfree'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_M001')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_M001', N'MAC Studio Fix Fluid', N'mac-studio-fix-fluid', N'Phấn nền lỏng che phủ cao', 550000, 650000, 50, N'images/SP/M001.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'mac'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_M002')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_M002', N'MAC Ruby Woo', N'mac-ruby-woo', N'Son môi Ruby Woo nổi tiếng', 385000, NULL, 90, N'images/SP/M002.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'mac'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_M003')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_M003', N'MAC Chili', N'mac-chili', N'Son môi Chili', 385000, NULL, 85, N'images/SP/M003.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'mac'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_M004')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_M004', N'MAC Fix+ Spray', N'mac-fix-spray', N'Xịt cố định lớp trang điểm', 345000, 420000, 60, N'images/SP/M004.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'mac'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_M005')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_M005', N'MAC Prep Prime', N'mac-prep-prime', N'Kem lót dưỡng da', 425000, NULL, 50, N'images/SP/M005.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'mac'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_M006')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_M006', N'MAC Pro Longwear', N'mac-pro-longwear', N'Phấn nền lâu trôi', 525000, 620000, 40, N'images/SP/M006.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'mac'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_M007')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_M007', N'MAC Mineralize', N'mac-mineralize', N'Phấn nền khoáng', 495000, NULL, 45, N'images/SP/M007.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'mac'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-nhay-cam'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_M008')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_M008', N'MAC Paint Pot', N'mac-paint-pot', N'Phấn lót mắt đa năng', 345000, NULL, 60, N'images/SP/M008.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'mac'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_M009')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_M009', N'MAC Eye Shadow', N'mac-eye-shadow', N'Phấn mắt đơn sắc', 285000, 350000, 75, N'images/SP/M009.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'mac'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_M010')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_M010', N'MAC Palette', N'mac-palette', N'Bảng phấn mắt 12 màu', 685000, NULL, 30, N'images/SP/M010.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'mac'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_M011')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_M011', N'MAC Blush', N'mac-blush', N'Phấn má hồng khoáng', 365000, NULL, 55, N'images/SP/M011.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'mac'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_M012')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_M012', N'MAC Concealer', N'mac-concealer', N'Che khuyết điểm che phủ', 325000, NULL, 65, N'images/SP/M012.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'mac'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_M013')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_M013', N'MAC Lipglass', N'mac-lipglass', N'Son bóng', 365000, 420000, 55, N'images/SP/M013.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'mac'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_M014')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_M014', N'MAC Matte Lipstick', N'mac-matte-lipstick', N'Son lì matte', 385000, NULL, 80, N'images/SP/M014.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'mac'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_M015')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_M015', N'MAC Brow Pencil', N'mac-brow-pencil', N'Bút chì lông mày', 285000, NULL, 65, N'images/SP/M015.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'mac'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_M016')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_M016', N'MAC Zoom Lash', N'mac-zoom-lash', N'Mascara tăng cường mi', 385000, NULL, 65, N'images/SP/M016.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'mac'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_M017')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_M017', N'MAC Chromographic', N'mac-chromographic', N'Bút kẻ mắt nước chống nước', 285000, NULL, 70, N'images/SP/M017.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'mac'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_M018')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_M018', N'MAC Pro Eye Paint', N'mac-pro-eye-paint', N'Kẻ mắt dạng kem', 325000, 380000, 55, N'images/SP/M018.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'mac'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_M019')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_M019', N'MAC Setting Powder', N'mac-setting-powder', N'Phấn phủ mịn màng', 445000, NULL, 45, N'images/SP/M019.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'mac'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_M020')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_M020', N'MAC Strobe Cream', N'mac-strobe-cream', N'Kem highlight lấp lánh', 465000, NULL, 45, N'images/SP/M020.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'mac'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_M021')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_M021', N'MAC Lip Pencil', N'mac-lip-pencil', N'Bút kẻ môi', 245000, NULL, 70, N'images/SP/M021.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'mac'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_M022')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_M022', N'MAC Satin Lipstick', N'mac-satin-lipstick', N'Son satin mịn màng', 385000, NULL, 75, N'images/SP/M022.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'mac'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_M023')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_M023', N'MAC Cremesheen', N'mac-cremesheen', N'Son crem sheen dưỡng', 385000, NULL, 70, N'images/SP/M023.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'mac'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_M024')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_M024', N'MAC Brow Gel', N'mac-brow-gel', N'Gel lông mày', 325000, 380000, 50, N'images/SP/M024.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'mac'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_M025')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_M025', N'MAC Cleanse', N'mac-cleanse', N'Nước tẩy trang MAC', 445000, NULL, 40, N'images/SP/M025.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'mac'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_M026')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_M026', N'MAC Retro', N'mac-retro-lipstick', N'Son môi Retro', 385000, NULL, 80, N'images/SP/M026.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'mac'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_M027')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_M027', N'MAC Face and Body', N'mac-face-body', N'Phấn nền cho body và mặt', 485000, NULL, 45, N'images/SP/M027.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'mac'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_M028')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_M028', N'MAC Studio Sculpt', N'mac-studio-sculpt', N'Phấn nền dạng kem', 515000, NULL, 40, N'images/SP/M028.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'mac'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_M029')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_M029', N'MAC Mineralize Blush', N'mac-mineralize-blush', N'Phấn má khoáng bóng', 395000, 450000, 50, N'images/SP/M029.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'mac'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_M030')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_M030', N'MAC False Lash', N'mac-false-lash', N'Mascara giả mi', 425000, NULL, 50, N'images/SP/M030.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'mac'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_D001')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_D001', N'Dior Addict Lipstick', N'dior-addict-lipstick', N'Son Dior Addict', 550000, 650000, 50, N'images/SP/D001.png', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'dior'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_D002')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_D002', N'Dior Backstage Eye Palette', N'dior-eye-palette', N'Bảng mắt Dior Backstage', 685000, NULL, 35, N'images/SP/D002.png', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'dior'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_D003')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_D003', N'Dior Foundation', N'dior-foundation', N'Phấn nền Dior Forever', 750000, 850000, 40, N'images/SP/D003.png', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'dior'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_D004')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_D004', N'Dior Miss Dior', N'dior-miss-dior', N'Nước hoa Miss Dior', 1650000, NULL, 25, N'images/SP/D004.png', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'perfume'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'dior'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_D005')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_D005', N'Dior Sauvage', N'dior-sauvage', N'Nước hoa nam Dior Sauvage', 1850000, NULL, 30, N'images/SP/D005.png', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'perfume'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'dior'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_D006')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_D006', N'Dior Capture Totale', N'dior-capture-totale', N'Kem dưỡng chống lão hóa', 1850000, 2200000, 20, N'images/SP/D006.png', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'dior'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_D007')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_D007', N'Dior Hydra Life', N'dior-hydra-life', N'Kem dưỡng ẩm Dior Hydra Life', 925000, NULL, 25, N'images/SP/D007.png', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'dior'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_D008')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_D008', N'Dior J''adore', N'dior-jadore', N'Nước hoa J''adore', 1950000, NULL, 20, N'images/SP/D008.png', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'perfume'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'dior'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_D009')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_D009', N'Dior Lip Oil', N'dior-lip-oil', N'Dầu dưỡng môi Dior', 425000, 500000, 55, N'images/SP/D009.png', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'dior'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_D010')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_D010', N'Dior Forever Concealer', N'dior-concealer', N'Che khuyết điểm Dior', 485000, NULL, 45, N'images/SP/D010.png', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'dior'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_D011')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_D011', N'Dior Prestige Cream', N'dior-prestige', N'Kem dưỡng cao cấp Dior', 2250000, NULL, 15, N'images/SP/D011.png', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'dior'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_D012')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_D012', N'Dior Poison', N'dior-poison', N'Nước hoa Poison', 1450000, NULL, 18, N'images/SP/D012.png', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'perfume'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'dior'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_D013')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_D013', N'Dior Eye Cream', N'dior-eye-cream', N'Kem dưỡng mắt Dior', 925000, NULL, 30, N'images/SP/D013.png', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'dior'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_D014')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_D014', N'Dior Face Primer', N'dior-primer', N'Kem lót Dior', 625000, 750000, 40, N'images/SP/D014.png', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'dior'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_D015')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_D015', N'Dior Bronzer', N'dior-bronzer', N'Phấn tạo tông nâu', 545000, NULL, 30, N'images/SP/D015.png', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'dior'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_D016')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_D016', N'Dior Serum Essence', N'dior-serum', N'Tinh chất serum Dior', 1150000, NULL, 25, N'images/SP/D016.png', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'dior'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_D017')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_D017', N'Dior Toner', N'dior-toner', N'Nước hoa hồng Dior', 485000, NULL, 40, N'images/SP/D017.png', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'dior'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_D018')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_D018', N'Dior Cleansing', N'dior-cleansing', N'Sữa rửa mặt Dior', 525000, 620000, 35, N'images/SP/D018.png', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'dior'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_D019')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_D019', N'Dior Mask', N'dior-mask', N'Mặt nạ Dior', 685000, NULL, 25, N'images/SP/D019.png', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'dior'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_D020')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_D020', N'Dior Body Cream', N'dior-body-cream', N'Kem dưỡng thể Dior', 785000, NULL, 30, N'images/SP/D020.png', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'dior'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_D021')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_D021', N'Dior Hand Cream', N'dior-hand-cream', N'Kem dưỡng tay Dior', 385000, NULL, 50, N'images/SP/D021.png', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'dior'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_D022')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_D022', N'Dior Hair Perfume', N'dior-hair-perfume', N'Nước hoa tóc Dior', 625000, NULL, 35, N'images/SP/D022.png', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'haircare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'dior'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_D023')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_D023', N'Dior Shampoo', N'dior-shampoo', N'Dầu gội Dior', 485000, NULL, 30, N'images/SP/D023.png', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'haircare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'dior'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.5, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_D024')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_D024', N'Dior Lip Balm', N'dior-lip-balm', N'Son dưỡng môi Dior', 325000, NULL, 60, N'images/SP/D024.png', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'dior'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_D025')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_D025', N'Dior Palette Holiday', N'dior-palette-holiday', N'Bảng mắt Holiday', 985000, NULL, 20, N'images/SP/D025.png', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'dior'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_D026')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_D026', N'Dior Forever Cushion', N'dior-cushion', N'Cushion Dior Forever', 685000, NULL, 35, N'images/SP/D026.png', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'dior'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_D027')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_D027', N'Dior Addict Gloss', N'dior-gloss', N'Son bóng Dior', 420000, NULL, 50, N'images/SP/D027.png', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'dior'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_D028')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_D028', N'Dior Mono Eyeshadow', N'dior-mono', N'Phấn mắt đơn sắc', 285000, NULL, 40, N'images/SP/D028.png', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'dior'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_D029')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_D029', N'Dior Eyeliner Pen', N'dior-eyeliner', N'Bút kẻ mắt Dior', 315000, NULL, 45, N'images/SP/D029.png', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'dior'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_D030')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_D030', N'Dior Brow Styler', N'dior-brow', N'Bút kẻ mày Dior', 285000, NULL, 50, N'images/SP/D030.png', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'dior'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_O001')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_O001', N'Niacinamide 10% + Zinc 1%', N'to-niacinamide', NULL, 195000, 250000, 100, N'images/SP/O001.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'theordinary'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_O002')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_O002', N'Hyaluronic Acid 2% + B5', N'to-ha-b5', NULL, 210000, NULL, 85, N'images/SP/O002.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'theordinary'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_O003')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_O003', N'AHA 30% + BHA 2% Peeling', N'to-peeling', NULL, 245000, 300000, 60, N'images/SP/O003.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'theordinary'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-hon-hop'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_O004')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_O004', N'Caffeine Solution 5%', N'to-caffeine', NULL, 225000, NULL, 55, N'images/SP/O004.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'theordinary'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_O005')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_O005', N'Natural Moisturizing Factors', N'to-nmf', NULL, 185000, 220000, 70, N'images/SP/O005.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'theordinary'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.5, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_O006')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_O006', N'Glycolic Acid 7% Toning', N'to-glycolic', NULL, 320000, NULL, 40, N'images/SP/O006.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'theordinary'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_O007')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_O007', N'Alpha Arbutin 2% + HA', N'to-alpha', NULL, 285000, NULL, 65, N'images/SP/O007.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'theordinary'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_O008')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_O008', N'Squalane Cleanser', N'to-squalane', NULL, 265000, NULL, 50, N'images/SP/O008.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'theordinary'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-nhay-cam'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_O009')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_O009', N'Multi-Peptide Buffet', N'to-buffet', NULL, 450000, 520000, 30, N'images/SP/O009.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'theordinary'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_O010')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_O010', N'Lactic Acid 10% + HA', N'to-lactic', NULL, 235000, NULL, 45, N'images/SP/O010.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'theordinary'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_O011')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_O011', N'Retinol 0.5% in Squalane', N'to-retinol', NULL, 245000, NULL, 35, N'images/SP/O011.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'theordinary'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_O012')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_O012', N'Vitamin C Suspension 23%', N'to-vitc-23', NULL, 215000, NULL, 50, N'images/SP/O012.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'theordinary'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.4, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_O013')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_O013', N'Rose Hip Seed Oil', N'to-rose-hip', NULL, 310000, NULL, 40, N'images/SP/O013.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'theordinary'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_O014')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_O014', N'Azelaic Acid 10%', N'to-azelaic', NULL, 275000, NULL, 60, N'images/SP/O014.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'theordinary'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_O015')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_O015', N'Salicylic Acid Masque', N'to-bha-mask', NULL, 350000, NULL, 45, N'images/SP/O015.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'theordinary'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_O016')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_O016', N'Matrixyl 10% + HA', N'to-matrixyl', NULL, 380000, NULL, 25, N'images/SP/O016.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'theordinary'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_O017')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_O017', N'Amino Acids + B5', N'to-amino', NULL, 240000, NULL, 40, N'images/SP/O017.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'theordinary'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_O018')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_O018', N'Granactive Retinoid 2%', N'to-retinoid', NULL, 330000, NULL, 35, N'images/SP/O018.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'theordinary'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_O019')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_O019', N'Borage Seed Oil', N'to-borage', NULL, 215000, NULL, 30, N'images/SP/O019.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'theordinary'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-nhay-cam'), 4.5, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_O020')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_O020', N'Argireline 10%', N'to-argireline', NULL, 270000, NULL, 40, N'images/SP/O020.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'theordinary'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_O021')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_O021', N'Niacinamide Powder', N'to-powder', NULL, 220000, NULL, 50, N'images/SP/O021.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'theordinary'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_O022')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_O022', N'Pycnogenol 5%', N'to-pycnogenol', NULL, 310000, NULL, 20, N'images/SP/O022.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'theordinary'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_O023')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_O023', N'Resveratrol 3% + Ferulic', N'to-resveratrol', NULL, 265000, NULL, 30, N'images/SP/O023.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'theordinary'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_O024')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_O024', N'Hemi-Squalane', N'to-hemi', NULL, 165000, NULL, 55, N'images/SP/O024.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'haircare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'theordinary'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.5, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_O025')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_O025', N'Lash Serum', N'to-lash', NULL, 420000, NULL, 40, N'images/SP/O025.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'theordinary'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_O026')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_O026', N'Ascorbyl Glucoside 12%', N'to-vitc-liquid', NULL, 360000, NULL, 35, N'images/SP/O026.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'theordinary'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_O027')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_O027', N'EUK 134 0.1%', N'to-euk', NULL, 290000, NULL, 20, N'images/SP/O027.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'theordinary'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_O028')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_O028', N'Mineral UV SPF 30', N'to-sun', NULL, 320000, NULL, 40, N'images/SP/O028.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'theordinary'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-nhay-cam'), 4.3, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_O029')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_O029', N'Hair Serum Peptide', N'to-hair', NULL, 540000, 650000, 25, N'images/SP/O029.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'haircare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'theordinary'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_O030')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_O030', N'Vitamin C Powder 100%', N'to-vitc-powder', NULL, 195000, NULL, 45, N'images/SP/O030.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'theordinary'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_LR001')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_LR001', N'Effaclar Duo Plus', N'lrp-duo-plus', NULL, 425000, 495000, 80, N'images/SP/LR001.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'larocheposay'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_LR002')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_LR002', N'Sữa rửa mặt Effaclar Gel', N'lrp-gel', NULL, 355000, NULL, 120, N'images/SP/LR002.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'larocheposay'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_LR003')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_LR003', N'Cicaplast Baume B5', N'lrp-b5', NULL, 315000, 360000, 150, N'images/SP/LR003.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'larocheposay'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-nhay-cam'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_LR004')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_LR004', N'Anthelios Invisible Fluid', N'lrp-sun-fluid', NULL, 465000, 520000, 100, N'images/SP/LR004.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'larocheposay'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_LR005')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_LR005', N'Hyalu B5 Serum', N'lrp-hyalu-b5', NULL, 850000, 990000, 40, N'images/SP/LR005.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'larocheposay'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_LR006')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_LR006', N'Serum Pure Vitamin C10', N'lrp-vit-c', NULL, 920000, NULL, 35, N'images/SP/LR006.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'larocheposay'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_LR007')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_LR007', N'Toleriane Sensitive Cream', N'lrp-toleriane', NULL, 445000, NULL, 60, N'images/SP/LR007.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'larocheposay'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-nhay-cam'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_LR008')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_LR008', N'Effaclar Mat', N'lrp-mat', NULL, 385000, NULL, 50, N'images/SP/LR008.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'larocheposay'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.5, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_LR009')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_LR009', N'Micellar Water Ultra', N'lrp-micellar', NULL, 395000, 450000, 90, N'images/SP/LR009.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'larocheposay'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-nhay-cam'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_LR010')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_LR010', N'Lipikar Baume AP+M', N'lrp-lipikar', NULL, 580000, NULL, 45, N'images/SP/LR010.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'larocheposay'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_LR011')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_LR011', N'Serozinc Spray', N'lrp-serozinc', NULL, 285000, NULL, 70, N'images/SP/LR011.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'larocheposay'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_LR012')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_LR012', N'Cicaplast Mains', N'lrp-hand', NULL, 225000, NULL, 60, N'images/SP/LR012.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'larocheposay'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_LR013')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_LR013', N'Cicaplast Levres', N'lrp-lip', NULL, 185000, NULL, 100, N'images/SP/LR013.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'larocheposay'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_LR014')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_LR014', N'Effaclar Serum Peel', N'lrp-peel', NULL, 820000, 950000, 30, N'images/SP/LR014.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'larocheposay'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_LR015')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_LR015', N'Effaclar H Iso-Biome', N'lrp-iso-biome', NULL, 415000, NULL, 40, N'images/SP/LR015.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'larocheposay'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_LR016')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_LR016', N'Pigmentclar Serum', N'lrp-pigment', NULL, 1050000, NULL, 20, N'images/SP/LR016.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'larocheposay'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_LR017')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_LR017', N'Hydreane Light', N'lrp-hydreane', NULL, 365000, NULL, 45, N'images/SP/LR017.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'larocheposay'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-hon-hop'), 4.5, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_LR018')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_LR018', N'Lipikar Oil Cleanser', N'lrp-oil', NULL, 495000, NULL, 35, N'images/SP/LR018.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'larocheposay'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_LR019')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_LR019', N'Anthelios Sun Stick', N'lrp-stick', NULL, 325000, NULL, 50, N'images/SP/LR019.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'larocheposay'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_LR020')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_LR020', N'Posthelios After Sun', N'lrp-after-sun', NULL, 415000, NULL, 30, N'images/SP/LR020.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'larocheposay'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_LR021')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_LR021', N'Kerium DS Shampoo', N'lrp-shampoo', NULL, 385000, NULL, 40, N'images/SP/LR021.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'haircare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'larocheposay'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_LR022')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_LR022', N'Cicaplast Spray B5', N'lrp-spray', NULL, 345000, NULL, 55, N'images/SP/LR022.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'larocheposay'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-nhay-cam'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_LR023')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_LR023', N'Rosaliac AR Intense', N'lrp-rosaliac', NULL, 625000, NULL, 25, N'images/SP/LR023.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'larocheposay'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-nhay-cam'), 4.5, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_LR024')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_LR024', N'Anthelios Kids Lotion', N'lrp-kids', NULL, 485000, NULL, 35, N'images/SP/LR024.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'larocheposay'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_LR025')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_LR025', N'Toleriane Teint Base', N'lrp-base', NULL, 525000, NULL, 30, N'images/SP/LR025.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'larocheposay'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-nhay-cam'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_LR026')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_LR026', N'Toleriane Foaming Cleanser', N'lrp-foam', NULL, 395000, NULL, 60, N'images/SP/LR026.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'larocheposay'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_LR027')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_LR027', N'Uvidea Anthelios Tone-Up', N'lrp-tone-up', NULL, 545000, 620000, 40, N'images/SP/LR027.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'larocheposay'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_LR028')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_LR028', N'Cicaplast Gel B5', N'lrp-gel-b5', NULL, 335000, NULL, 45, N'images/SP/LR028.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'larocheposay'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_LR029')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_LR029', N'Lipikar Syndet AP+', N'lrp-syndet', NULL, 425000, NULL, 50, N'images/SP/LR029.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'larocheposay'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_LR030')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_LR030', N'Anthelios Tinted Fluid', N'lrp-tinted', NULL, 475000, NULL, 35, N'images/SP/LR030.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'larocheposay'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_C001')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_C001', N'Tẩy da chết Cà phê Đắk Lắk Body', N'cocoon-coffee-body', NULL, 165000, 210000, 200, N'images/SP/C001.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'cocoon'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_C002')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_C002', N'Nước hoa hồng Sen Hậu Giang', N'cocoon-toner-sen', NULL, 175000, NULL, 120, N'images/SP/C002.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'cocoon'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_C003')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_C003', N'Serum Bí Đao', N'cocoon-serum-bidao', NULL, 265000, 295000, 100, N'images/SP/C003.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'cocoon'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_C004')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_C004', N'Gel rửa mặt Bí Đao', N'cocoon-cleanser-bidao', NULL, 155000, NULL, 140, N'images/SP/C004.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'cocoon'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_C005')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_C005', N'Tinh dầu bưởi mọc tóc', N'cocoon-pomelo', NULL, 145000, NULL, 180, N'images/SP/C005.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'haircare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'cocoon'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_C006')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_C006', N'Thạch hoa hồng dưỡng ẩm', N'cocoon-rose-gel', NULL, 185000, NULL, 80, N'images/SP/C006.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'cocoon'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_C007')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_C007', N'Mặt nạ Nghệ Hưng Yên', N'cocoon-turmeric-mask', NULL, 325000, NULL, 70, N'images/SP/C007.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'cocoon'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_C008')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_C008', N'Nước tẩy trang Hoa Hồng', N'cocoon-rose-water', NULL, 245000, NULL, 110, N'images/SP/C008.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'cocoon'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_C009')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_C009', N'Son dưỡng Dừa Bến Tre', N'cocoon-coconut-lip', NULL, 35000, 45000, 300, N'images/SP/C009.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'cocoon'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_C010')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_C010', N'Cao vỏ bưởi dưỡng tóc', N'cocoon-pomelo-cream', NULL, 165000, NULL, 90, N'images/SP/C010.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'haircare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'cocoon'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_C011')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_C011', N'Tẩy da chết Môi Cà phê', N'cocoon-coffee-lip', NULL, 75000, NULL, 250, N'images/SP/C011.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'cocoon'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_C012')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_C012', N'Mặt nạ Bí Đao', N'cocoon-winter-melon-mask', NULL, 145000, NULL, 85, N'images/SP/C012.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'cocoon'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_C013')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_C013', N'Dầu gội bưởi không Sulfate', N'cocoon-pomelo-shampoo', NULL, 225000, NULL, 130, N'images/SP/C013.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'haircare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'cocoon'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_C014')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_C014', N'Dầu xả bưởi phục hồi', N'cocoon-pomelo-conditioner', NULL, 225000, NULL, 130, N'images/SP/C014.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'haircare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'cocoon'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_C015')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_C015', N'Nước dưỡng tóc Sa-chi', N'cocoon-sachi-hair', NULL, 125000, NULL, 100, N'images/SP/C015.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'haircare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'cocoon'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.5, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_C016')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_C016', N'Serum Nghệ Hưng Yên', N'cocoon-turmeric-serum', NULL, 295000, 350000, 60, N'images/SP/C016.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'cocoon'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_C017')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_C017', N'Tẩy da chết Cà phê Mặt', N'cocoon-coffee-face', NULL, 145000, NULL, 150, N'images/SP/C017.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'cocoon'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_C018')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_C018', N'Xịt khoáng sen Hậu Giang', N'cocoon-sen-mist', NULL, 135000, NULL, 140, N'images/SP/C018.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'cocoon'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_C019')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_C019', N'Bơ dưỡng thể Đắk Lắk', N'cocoon-coffee-butter', NULL, 185000, NULL, 90, N'images/SP/C019.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'cocoon'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_C020')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_C020', N'Dầu tắm bạch đàn & bạc hà', N'cocoon-body-wash', NULL, 215000, NULL, 100, N'images/SP/C020.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'cocoon'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_C021')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_C021', N'Kem dưỡng Nghệ Hưng Yên', N'cocoon-turmeric-cream', NULL, 285000, NULL, 55, N'images/SP/C021.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'cocoon'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_C022')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_C022', N'Nước cân bằng Bí Đao', N'cocoon-winter-melon-toner', NULL, 165000, NULL, 90, N'images/SP/C022.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'cocoon'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_C023')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_C023', N'Gel tắm Bí Đao', N'cocoon-winter-melon-wash', NULL, 195000, NULL, 120, N'images/SP/C023.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'cocoon'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_C024')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_C024', N'Mặt nạ Hoa Hồng dưỡng ẩm', N'cocoon-rose-mask', NULL, 145000, NULL, 80, N'images/SP/C024.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'cocoon'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_C025')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_C025', N'Dầu gội Sa-chi phục hồi', N'cocoon-sachi-shampoo', NULL, 245000, NULL, 100, N'images/SP/C025.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'haircare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'cocoon'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_C026')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_C026', N'Serum Sa-chi dưỡng tóc', N'cocoon-sachi-serum', NULL, 155000, NULL, 95, N'images/SP/C026.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'haircare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'cocoon'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_C027')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_C027', N'Xà phòng Cà phê Đắk Lắk', N'cocoon-coffee-soap', NULL, 55000, NULL, 200, N'images/SP/C027.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'cocoon'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_C028')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_C028', N'Kem dưỡng tay Sen Hậu Giang', N'cocoon-sen-hand', NULL, 85000, NULL, 150, N'images/SP/C028.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'cocoon'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.5, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_C029')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_C029', N'Cao bí đao trị mụn', N'cocoon-winter-melon-cao', NULL, 95000, NULL, 70, N'images/SP/C029.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'cocoon'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_C030')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_C030', N'Nước tẩy trang Bí Đao 500ml', N'cocoon-bidao-water-large', NULL, 275000, 320000, 100, N'images/SP/C030.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'cocoon'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_G001')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_G001', N'Nước tẩy trang Micellar Hồng', N'garnier-micellar-pink', NULL, 165000, 195000, 250, N'images/SP/G001.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'garnier'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-nhay-cam'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_G002')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_G002', N'Nước tẩy trang Micellar Vàng Oil', N'garnier-micellar-oil', NULL, 185000, NULL, 200, N'images/SP/G002.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'garnier'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_G003')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_G003', N'Serum Vitamin C sáng da', N'garnier-vitc-serum', NULL, 255000, 310000, 150, N'images/SP/G003.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'garnier'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_G004')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_G004', N'Sữa rửa mặt sáng da Bright', N'garnier-bright-wash', NULL, 115000, NULL, 180, N'images/SP/G004.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'garnier'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_G005')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_G005', N'Kem dưỡng Serum Cream SPF30', N'garnier-serum-cream', NULL, 195000, NULL, 100, N'images/SP/G005.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'garnier'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_G006')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_G006', N'Mặt nạ Serum Mask Sakura', N'garnier-Sakura-mask', NULL, 32000, 45000, 500, N'images/SP/G006.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'garnier'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_G007')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_G007', N'Mặt nạ Serum Mask Vitamin C', N'garnier-vitc-mask', NULL, 32000, 45000, 500, N'images/SP/G007.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'garnier'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_G008')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_G008', N'Kem dưỡng ban đêm Bright', N'garnier-night-cream', NULL, 215000, NULL, 90, N'images/SP/G008.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'garnier'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_G009')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_G009', N'Tẩy da chết AHA/BHA Serum', N'garnier-aha-bha', NULL, 285000, 350000, 70, N'images/SP/G009.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'garnier'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_G010')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_G010', N'Lăn khử mùi Mineral', N'garnier-deo', NULL, 85000, NULL, 300, N'images/SP/G010.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'garnier'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.5, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_G011')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_G011', N'Serum chống nắng SPF50', N'garnier-sun-serum', NULL, 235000, NULL, 110, N'images/SP/G011.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'garnier'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_G012')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_G012', N'Nước tẩy trang Micellar xanh dương', N'garnier-micellar-blue', NULL, 165000, NULL, 180, N'images/SP/G012.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'garnier'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_G013')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_G013', N'Kem trị mụn nhanh Garnier', N'garnier-acne', NULL, 145000, NULL, 95, N'images/SP/G013.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'garnier'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_G014')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_G014', N'Mặt nạ Serum Mask Green Tea', N'garnier-tea-mask', NULL, 32000, NULL, 400, N'images/SP/G014.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'garnier'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_G015')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_G015', N'Mặt nạ Serum Mask Lavender', N'garnier-lavender-mask', NULL, 32000, NULL, 350, N'images/SP/G015.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'garnier'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_G016')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_G016', N'Serum Vitamin C tinh khiết ban đêm', N'garnier-night-serum', NULL, 295000, 360000, 65, N'images/SP/G016.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'garnier'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_G017')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_G017', N'Sữa rửa mặt giảm mụn Acne', N'garnier-acne-wash', NULL, 125000, NULL, 130, N'images/SP/G017.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'garnier'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_G018')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_G018', N'Mặt nạ Serum Mask Charcoal', N'garnier-charcoal-mask', NULL, 35000, NULL, 200, N'images/SP/G018.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'garnier'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_G019')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_G019', N'Sữa dưỡng thể sáng da Bright', N'garnier-body-lotion', NULL, 175000, NULL, 110, N'images/SP/G019.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'garnier'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_G020')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_G020', N'Thuốc nhuộm tóc Garnier đen', N'garnier-hair-black', NULL, 45000, NULL, 150, N'images/SP/G020.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'haircare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'garnier'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.4, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_G021')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_G021', N'Thuốc nhuộm tóc Garnier nâu', N'garnier-hair-brown', NULL, 45000, NULL, 150, N'images/SP/G021.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'haircare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'garnier'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.5, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_G022')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_G022', N'Kem dưỡng ẩm Aqua Bomb', N'garnier-aqua-bomb', NULL, 285000, NULL, 50, N'images/SP/G022.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'garnier'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_G023')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_G023', N'Mặt nạ mắt cam giảm quầng thâm', N'garnier-eye-orange', NULL, 35000, NULL, 300, N'images/SP/G023.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'garnier'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_G024')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_G024', N'Mặt nạ mắt dừa cấp ẩm', N'garnier-eye-coconut', NULL, 35000, NULL, 300, N'images/SP/G024.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'garnier'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_G025')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_G025', N'Gel dưỡng sáng Sakura', N'garnier-sakura-gel', NULL, 185000, NULL, 80, N'images/SP/G025.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'garnier'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_G026')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_G026', N'Nước Micellar hồng nắp vàng', N'garnier-micellar-peeling', NULL, 195000, NULL, 120, N'images/SP/G026.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'garnier'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_G027')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_G027', N'Xà phòng rửa mặt than tre', N'garnier-soap-charcoal', NULL, 95000, NULL, 100, N'images/SP/G027.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'garnier'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-dau'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_G028')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_G028', N'Tẩy da chết hạt mơ Garnier', N'garnier-apricot-scrub', NULL, 135000, NULL, 110, N'images/SP/G028.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'garnier'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.5, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_G029')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_G029', N'Sữa dưỡng thể Sakura', N'garnier-sakura-body', NULL, 175000, NULL, 90, N'images/SP/G029.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'garnier'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_G030')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_G030', N'Kem lót Garnier Blur', N'garnier-blur', NULL, 225000, NULL, 70, N'images/SP/G030.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'garnier'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.4, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_Y001')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_Y001', N'Son YSL The Slim Velvet Radical', N'ysl-the-slim', NULL, 950000, 1100000, 40, N'images/SP/Y001.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'ysl'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_Y002')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_Y002', N'Nước hoa Libre EDP 50ml', N'ysl-libre-edp', NULL, 2850000, 3200000, 25, N'images/SP/Y002.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'perfume'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'ysl'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_Y003')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_Y003', N'Cushion Le Cushion Encre De Peau', N'ysl-cushion', NULL, 1650000, 1850000, 35, N'images/SP/Y003.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'ysl'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_Y004')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_Y004', N'Kem nền All Hours Foundation', N'ysl-foundation', NULL, 1450000, NULL, 30, N'images/SP/Y004.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'ysl'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_Y005')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_Y005', N'Son dưỡng YSL Rouge Volupte Shine', N'ysl-shine', NULL, 880000, NULL, 50, N'images/SP/Y005.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'ysl'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_Y006')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_Y006', N'Nước hoa Black Opium EDP', N'ysl-black-opium', NULL, 2750000, NULL, 20, N'images/SP/Y006.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'perfume'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'ysl'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_Y007')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_Y007', N'Serum Pure Shots Night Reboot', N'ysl-pure-shots', NULL, 2200000, 2500000, 15, N'images/SP/Y007.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'ysl'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_Y008')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_Y008', N'Kem lót Touche Eclat Blur Primer', N'ysl-blur-primer', NULL, 1250000, NULL, 20, N'images/SP/Y008.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'ysl'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_Y009')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_Y009', N'Bút che khuyết điểm Touche Eclat', N'ysl-concealer', NULL, 950000, NULL, 40, N'images/SP/Y009.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'ysl'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_Y010')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_Y010', N'Nước hoa Mon Paris EDP', N'ysl-mon-paris', NULL, 2650000, NULL, 25, N'images/SP/Y010.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'perfume'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'ysl'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_Y011')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_Y011', N'Son kem YSL Vinyl Cream Lip Stain', N'ysl-vinyl', NULL, 920000, NULL, 45, N'images/SP/Y011.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'ysl'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_Y012')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_Y012', N'Phấn phủ Souffle D Eclat', N'ysl-powder', NULL, 1350000, NULL, 20, N'images/SP/Y012.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'ysl'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_Y013')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_Y013', N'Mascara Volume Effet Faux Cils', N'ysl-mascara', NULL, 850000, NULL, 30, N'images/SP/Y013.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'ysl'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_Y014')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_Y014', N'Nước hoa YSL Y EDP For Men', N'ysl-y-edp', NULL, 2850000, NULL, 30, N'images/SP/Y014.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'perfume'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'ysl'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_Y015')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_Y015', N'Kem dưỡng Pure Shots Perfect Plumper', N'ysl-pure-cream', NULL, 2100000, NULL, 15, N'images/SP/Y015.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'ysl'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_Y016')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_Y016', N'Kẻ mắt nước YSL Shocking', N'ysl-liner', NULL, 750000, NULL, 30, N'images/SP/Y016.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'ysl'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.5, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_Y017')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_Y017', N'Son YSL Rouge Pur Couture', N'ysl-rouge', NULL, 880000, NULL, 40, N'images/SP/Y017.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'ysl'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_Y018')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_Y018', N'Nước hoa La Nuit De L Homme', N'ysl-la-nuit', NULL, 2450000, NULL, 20, N'images/SP/Y018.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'perfume'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'ysl'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_Y019')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_Y019', N'Sữa rửa mặt Pure Shots Cleanse', N'ysl-wash', NULL, 1200000, NULL, 25, N'images/SP/Y019.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'ysl'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_Y020')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_Y020', N'Kem dưỡng mắt Pure Shots Eye', N'ysl-eye', NULL, 1850000, NULL, 15, N'images/SP/Y020.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'ysl'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_Y021')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_Y021', N'Nước hoa Cinema EDP', N'ysl-cinema', NULL, 2350000, NULL, 10, N'images/SP/Y021.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'perfume'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'ysl'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_Y022')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_Y022', N'Phấn má YSL Couture Blush', N'ysl-blush', NULL, 1150000, NULL, 25, N'images/SP/Y022.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'ysl'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_Y023')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_Y023', N'Phấn mắt YSL Couture Palette', N'ysl-palette', NULL, 1550000, NULL, 15, N'images/SP/Y023.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'ysl'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_Y024')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_Y024', N'Nước tẩy trang Top Secrets', N'ysl-top-secrets', NULL, 1100000, NULL, 20, N'images/SP/Y024.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'ysl'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_Y025')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_Y025', N'Nước hoa L Homme EDT', N'ysl-lhomme', NULL, 2250000, NULL, 15, N'images/SP/Y025.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'perfume'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'ysl'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_Y026')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_Y026', N'Cushion Glow Mesh', N'ysl-mesh-cushion', NULL, 1750000, NULL, 20, N'images/SP/Y026.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'ysl'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_Y027')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_Y027', N'Dầu dưỡng môi Candy Glaze', N'ysl-candy', NULL, 950000, NULL, 35, N'images/SP/Y027.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'ysl'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_Y028')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_Y028', N'Nước hoa Manifestó EDP', N'ysl-manifesto', NULL, 2650000, NULL, 12, N'images/SP/Y028.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'perfume'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'ysl'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_Y029')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_Y029', N'Kem dưỡng tay YSL', N'ysl-hand', NULL, 650000, NULL, 30, N'images/SP/Y029.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'ysl'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.6, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_Y030')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_Y030', N'Serum Hydra Bounce Lotion', N'ysl-hydra', NULL, 1650000, NULL, 20, N'images/SP/Y030.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'ysl'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_CH001')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_CH001', N'Nước hoa Chanel No.5 EDP', N'chanel-no5', NULL, 4200000, 4600000, 10, N'images/SP/CH001.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'perfume'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'chanel'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 5, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_CH002')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_CH002', N'Nước hoa Bleu de Chanel EDP', N'chanel-bleu', NULL, 3500000, 3800000, 15, N'images/SP/CH002.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'perfume'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'chanel'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 5, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_CH003')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_CH003', N'Son Chanel Rouge Coco', N'chanel-coco', NULL, 1050000, 1200000, 30, N'images/SP/CH003.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'chanel'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_CH004')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_CH004', N'Kem nền Les Beiges Foundation', N'chanel-foundation', NULL, 1850000, NULL, 20, N'images/SP/CH004.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'chanel'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_CH005')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_CH005', N'Nước hoa Coco Mademoiselle', N'chanel-coco-mad', NULL, 4100000, NULL, 12, N'images/SP/CH005.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'perfume'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'chanel'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 5, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_CH006')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_CH006', N'Kem dưỡng Hydra Beauty Creme', N'chanel-hydra', NULL, 2200000, NULL, 15, N'images/SP/CH006.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'chanel'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'da-kho'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_CH007')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_CH007', N'Serum Le Lift', N'chanel-le-lift', NULL, 4500000, NULL, 10, N'images/SP/CH007.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'chanel'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_CH008')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_CH008', N'Phấn má Joues Contraste', N'chanel-blush', NULL, 1350000, NULL, 20, N'images/SP/CH008.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'chanel'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_CH009')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_CH009', N'Mascara Le Volume de Chanel', N'chanel-mascara', NULL, 950000, NULL, 25, N'images/SP/CH009.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'chanel'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_CH010')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_CH010', N'Sữa rửa mặt La Mousse', N'chanel-mousse', NULL, 1250000, 1450000, 40, N'images/SP/CH010.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'chanel'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_CH011')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_CH011', N'Nước hoa Chance Eau Tendre', N'chanel-chance', NULL, 3800000, NULL, 18, N'images/SP/CH011.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'perfume'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'chanel'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_CH012')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_CH012', N'Son kem Rouge Allure Ink', N'chanel-ink', NULL, 1100000, NULL, 25, N'images/SP/CH012.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'chanel'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_CH013')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_CH013', N'Phấn phủ Poudre Universelle', N'chanel-powder', NULL, 1550000, NULL, 20, N'images/SP/CH013.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'chanel'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_CH014')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_CH014', N'Nước hoa Allure Homme Sport', N'chanel-allure-sport', NULL, 3200000, NULL, 20, N'images/SP/CH014.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'perfume'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'chanel'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 5, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_CH015')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_CH015', N'Kem dưỡng mắt Sublimage La Creme', N'chanel-eye', NULL, 5500000, NULL, 8, N'images/SP/CH015.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'chanel'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 5, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_CH016')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_CH016', N'Kẻ mắt Chanel Stylo Yeux', N'chanel-pencil', NULL, 850000, NULL, 30, N'images/SP/CH016.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'chanel'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_CH017')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_CH017', N'Serum Hydra Beauty Micro', N'chanel-micro-serum', NULL, 3200000, NULL, 12, N'images/SP/CH017.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'chanel'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_CH018')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_CH018', N'Nước hoa Gabrielle Chanel', N'chanel-gabrielle', NULL, 4250000, NULL, 15, N'images/SP/CH018.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'perfume'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'chanel'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_CH019')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_CH019', N'Dầu tẩy trang Chanel Huile', N'chanel-oil', NULL, 1350000, NULL, 20, N'images/SP/CH019.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'chanel'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_CH020')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_CH020', N'Kem lót Chanel Base Lumiere', N'chanel-primer', NULL, 1450000, NULL, 20, N'images/SP/CH020.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'chanel'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_CH021')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_CH021', N'Nước hoa Egoiste Platinum', N'chanel-egoiste', NULL, 3100000, NULL, 10, N'images/SP/CH021.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'perfume'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'chanel'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_CH022')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_CH022', N'Phấn mắt Chanel Les 4 Ombres', N'chanel-eyeshadow', NULL, 1750000, NULL, 15, N'images/SP/CH022.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'chanel'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_CH023')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_CH023', N'Chì kẻ mày Chanel Crayon', N'chanel-brow', NULL, 950000, NULL, 25, N'images/SP/CH023.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'chanel'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.7, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_CH024')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_CH024', N'Nước cân bằng Chanel Lotion', N'chanel-toner', NULL, 1650000, NULL, 20, N'images/SP/CH024.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'chanel'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_CH025')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_CH025', N'Kem dưỡng Sublimage La Creme', N'chanel-sublimage', NULL, 9500000, NULL, 5, N'images/SP/CH025.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'chanel'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 5, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_CH026')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_CH026', N'Son dưỡng Chanel Boy', N'chanel-boy-lip', NULL, 1050000, NULL, 20, N'images/SP/CH026.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'makeup'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'chanel'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_CH027')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_CH027', N'Tẩy da chết Chanel Gommage', N'chanel-scrub', NULL, 1550000, NULL, 15, N'images/SP/CH027.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'cleansing'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'chanel'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_CH028')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_CH028', N'Nước hoa Sycomore Exclusif', N'chanel-sycomore', NULL, 6500000, NULL, 5, N'images/SP/CH028.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'perfume'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'chanel'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 5, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_CH029')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_CH029', N'Kem tay Chanel La Creme Main', N'chanel-hand', NULL, 1450000, NULL, 25, N'images/SP/CH029.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'skincare'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'chanel'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.9, 1;
END;
IF NOT EXISTS (SELECT 1 FROM dbo.SanPham WHERE FirebaseId = N'prod_CH030')
BEGIN
INSERT INTO dbo.SanPham (FirebaseId, TenSanPham, Slug, MoTa, Gia, GiaGoc, SoLuongKho, LinkAnh, MaDanhMuc, MaThuongHieu, MaLoaiDa, DanhGia, TrangThai) SELECT N'prod_CH030', N'Nước hoa Chanel No.19', N'chanel-no19', NULL, 3950000, NULL, 10, N'images/SP/CH030.jpg', (SELECT TOP (1) MaDanhMuc FROM dbo.DanhMuc WHERE Slug = N'perfume'), (SELECT TOP (1) MaThuongHieu FROM dbo.ThuongHieu WHERE Slug = N'chanel'), (SELECT TOP (1) MaLoaiDa FROM dbo.LoaiDa WHERE Slug = N'all'), 4.8, 1;
END;

COMMIT TRANSACTION;
-- END FIREBASE DATA SEED
