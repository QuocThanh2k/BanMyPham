SET XACT_ABORT ON;
BEGIN TRANSACTION;

DECLARE @roleConstraint sysname;
SELECT TOP (1) @roleConstraint = cc.name
FROM sys.check_constraints cc
WHERE cc.parent_object_id = OBJECT_ID(N'dbo.KhachHang')
  AND cc.definition LIKE N'%VaiTro%';

IF @roleConstraint IS NOT NULL
BEGIN
  DECLARE @dropRoleConstraintSql nvarchar(max);
  SET @dropRoleConstraintSql = N'ALTER TABLE dbo.KhachHang DROP CONSTRAINT ' + QUOTENAME(@roleConstraint);
  EXEC sys.sp_executesql @dropRoleConstraintSql;
END;

IF NOT EXISTS (
  SELECT 1 FROM sys.check_constraints
  WHERE parent_object_id = OBJECT_ID(N'dbo.KhachHang')
    AND name = N'chk_khachhang_role'
)
  ALTER TABLE dbo.KhachHang
    ADD CONSTRAINT chk_khachhang_role CHECK (VaiTro IN (N'customer', N'admin', N'super_admin'));

UPDATE dbo.KhachHang
SET VaiTro = N'super_admin'
WHERE LOWER(Email) = N'quocthanh2614@gmail.com';

COMMIT TRANSACTION;
