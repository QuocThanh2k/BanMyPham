-- SQL Server migration for databases created before the expanded catalog schema.
SET XACT_ABORT ON;
BEGIN TRANSACTION;

IF OBJECT_ID(N'dbo.LoaiDa', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.LoaiDa (
    MaLoaiDa BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    TenLoaiDa NVARCHAR(100) NOT NULL,
    Slug NVARCHAR(80) NOT NULL UNIQUE,
    TrangThai BIT NOT NULL CONSTRAINT DF_LoaiDa_TrangThai DEFAULT (1)
  );
END;

IF COL_LENGTH(N'dbo.DanhMuc', N'Icon') IS NULL
  ALTER TABLE dbo.DanhMuc ADD Icon NVARCHAR(80) NULL;
IF COL_LENGTH(N'dbo.DanhMuc', N'TrangThai') IS NULL
  ALTER TABLE dbo.DanhMuc ADD TrangThai BIT NOT NULL CONSTRAINT DF_DanhMuc_TrangThai DEFAULT (1);

IF COL_LENGTH(N'dbo.ThuongHieu', N'TrangThai') IS NULL
  ALTER TABLE dbo.ThuongHieu ADD TrangThai BIT NOT NULL CONSTRAINT DF_ThuongHieu_TrangThai DEFAULT (1);

IF COL_LENGTH(N'dbo.SanPham', N'Slug') IS NULL
  ALTER TABLE dbo.SanPham ADD Slug NVARCHAR(255) NULL;
IF COL_LENGTH(N'dbo.SanPham', N'MaLoaiDa') IS NULL
  ALTER TABLE dbo.SanPham ADD MaLoaiDa BIGINT NULL;
IF COL_LENGTH(N'dbo.SanPham', N'DanhGia') IS NULL
  ALTER TABLE dbo.SanPham ADD DanhGia DECIMAL(2, 1) NULL;
IF COL_LENGTH(N'dbo.SanPham', N'TrangThai') IS NULL
  ALTER TABLE dbo.SanPham ADD TrangThai BIT NOT NULL CONSTRAINT DF_SanPham_TrangThai DEFAULT (1);

UPDATE dbo.SanPham
SET Slug = CONCAT(N'legacy-', CONVERT(NVARCHAR(30), MaSanPham))
WHERE Slug IS NULL;

ALTER TABLE dbo.SanPham ALTER COLUMN Slug NVARCHAR(255) NOT NULL;

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes
  WHERE name = N'uq_sanpham_slug' AND object_id = OBJECT_ID(N'dbo.SanPham')
)
  CREATE UNIQUE INDEX uq_sanpham_slug ON dbo.SanPham(Slug);

IF NOT EXISTS (
  SELECT 1 FROM sys.foreign_keys
  WHERE name = N'fk_sanpham_loaida' AND parent_object_id = OBJECT_ID(N'dbo.SanPham')
)
  ALTER TABLE dbo.SanPham
    ADD CONSTRAINT fk_sanpham_loaida
      FOREIGN KEY (MaLoaiDa) REFERENCES dbo.LoaiDa(MaLoaiDa) ON DELETE SET NULL;

COMMIT TRANSACTION;
