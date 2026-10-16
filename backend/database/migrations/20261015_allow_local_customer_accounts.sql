-- Allow accounts created by the website to omit FirebaseId while preserving
-- uniqueness for imported Firebase customer IDs.
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
SET XACT_ABORT ON;
BEGIN TRANSACTION;

DECLARE @firebaseConstraint sysname;
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

IF @firebaseConstraint IS NOT NULL
BEGIN
  DECLARE @dropFirebaseConstraintSql nvarchar(max);
  SET @dropFirebaseConstraintSql = N'ALTER TABLE dbo.KhachHang DROP CONSTRAINT ' + QUOTENAME(@firebaseConstraint);
  EXEC sys.sp_executesql @dropFirebaseConstraintSql;
END;

IF EXISTS (
  SELECT 1
  FROM sys.indexes
  WHERE object_id = OBJECT_ID(N'dbo.KhachHang')
    AND name = N'uq_khachhang_firebase_id'
    AND is_unique = 1
    AND has_filter = 0
)
  DROP INDEX uq_khachhang_firebase_id ON dbo.KhachHang;

IF NOT EXISTS (
  SELECT 1
  FROM sys.indexes
  WHERE object_id = OBJECT_ID(N'dbo.KhachHang')
    AND name = N'uq_khachhang_firebase_id'
)
  CREATE UNIQUE INDEX uq_khachhang_firebase_id
    ON dbo.KhachHang(FirebaseId)
    WHERE FirebaseId IS NOT NULL;

COMMIT TRANSACTION;
