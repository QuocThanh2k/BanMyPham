-- SQL Server migration for Firebase identifiers and account safety fields.
-- The Firebase data itself is included in schema.sql for new databases.
SET XACT_ABORT ON;
BEGIN TRANSACTION;

IF OBJECT_ID(N'dbo.ThongTinUngDung', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.ThongTinUngDung (
    Khoa NVARCHAR(100) NOT NULL PRIMARY KEY,
    GiaTri NVARCHAR(MAX) NOT NULL
  );
END;

IF COL_LENGTH(N'dbo.KhachHang', N'FirebaseId') IS NULL
  ALTER TABLE dbo.KhachHang ADD FirebaseId NVARCHAR(64) NULL;
IF COL_LENGTH(N'dbo.KhachHang', N'TaiKhoanHoatDong') IS NULL
  ALTER TABLE dbo.KhachHang ADD TaiKhoanHoatDong BIT NOT NULL CONSTRAINT DF_KhachHang_TaiKhoanHoatDong DEFAULT (1);
IF COL_LENGTH(N'dbo.KhachHang', N'CanDatLaiMatKhau') IS NULL
  ALTER TABLE dbo.KhachHang ADD CanDatLaiMatKhau BIT NOT NULL CONSTRAINT DF_KhachHang_CanDatLaiMatKhau DEFAULT (0);

IF COL_LENGTH(N'dbo.DanhMuc', N'FirebaseId') IS NULL
  ALTER TABLE dbo.DanhMuc ADD FirebaseId NVARCHAR(64) NULL;
IF COL_LENGTH(N'dbo.DanhMuc', N'SoLuongSanPham') IS NULL
  ALTER TABLE dbo.DanhMuc ADD SoLuongSanPham INT NOT NULL CONSTRAINT DF_DanhMuc_SoLuongSanPham DEFAULT (0);

IF COL_LENGTH(N'dbo.ThuongHieu', N'FirebaseId') IS NULL
  ALTER TABLE dbo.ThuongHieu ADD FirebaseId NVARCHAR(64) NULL;
IF COL_LENGTH(N'dbo.ThuongHieu', N'SoLuongSanPham') IS NULL
  ALTER TABLE dbo.ThuongHieu ADD SoLuongSanPham INT NOT NULL CONSTRAINT DF_ThuongHieu_SoLuongSanPham DEFAULT (0);

IF COL_LENGTH(N'dbo.LoaiDa', N'FirebaseId') IS NULL
  ALTER TABLE dbo.LoaiDa ADD FirebaseId NVARCHAR(64) NULL;
IF COL_LENGTH(N'dbo.SanPham', N'FirebaseId') IS NULL
  ALTER TABLE dbo.SanPham ADD FirebaseId NVARCHAR(64) NULL;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'uq_khachhang_firebase_id' AND object_id = OBJECT_ID(N'dbo.KhachHang'))
  CREATE UNIQUE INDEX uq_khachhang_firebase_id ON dbo.KhachHang(FirebaseId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'uq_danhmuc_firebase_id' AND object_id = OBJECT_ID(N'dbo.DanhMuc'))
  CREATE UNIQUE INDEX uq_danhmuc_firebase_id ON dbo.DanhMuc(FirebaseId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'uq_thuonghieu_firebase_id' AND object_id = OBJECT_ID(N'dbo.ThuongHieu'))
  CREATE UNIQUE INDEX uq_thuonghieu_firebase_id ON dbo.ThuongHieu(FirebaseId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'uq_loaida_firebase_id' AND object_id = OBJECT_ID(N'dbo.LoaiDa'))
  CREATE UNIQUE INDEX uq_loaida_firebase_id ON dbo.LoaiDa(FirebaseId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'uq_sanpham_firebase_id' AND object_id = OBJECT_ID(N'dbo.SanPham'))
  CREATE UNIQUE INDEX uq_sanpham_firebase_id ON dbo.SanPham(FirebaseId);

COMMIT TRANSACTION;
