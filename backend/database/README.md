# Cấu hình quản trị viên

## Tài khoản quản trị viên tổng

Email `quocthanh2614@gmail.com` được bảo lưu làm quản trị viên tổng. Khi đăng
nhập và xác thực, backend nhận diện vai trò này theo email nên không cần thay
đổi schema hiện có để vào trang quản trị. Tài khoản phải được tạo và xác minh
trước khi triển khai; đăng ký công khai cho email này bị chặn.

Migration
[`migrations/20261015_admin_roles.sql`](./migrations/20261015_admin_roles.sql)
có thể chạy để lưu vai trò `super_admin` trực tiếp trong cơ sở dữ liệu. Nếu
chạy, tài khoản cần tồn tại trước. Với cơ sở dữ liệu mới, `schema.sql` đã hỗ trợ
vai trò này.

## Phân quyền

- `customer`: mua sắm và quản lý tài khoản cá nhân.
- `admin`: quản lý sản phẩm, đơn hàng và trạng thái tài khoản khách hàng.
- `super_admin`: có toàn bộ quyền quản trị và là vai trò duy nhất được cấp hoặc
  thu hồi quyền `admin`.

Backend kiểm tra quyền và trạng thái tài khoản trên từng yêu cầu quản trị.
Ẩn sản phẩm là thao tác lưu trữ mềm; đơn hàng bị hủy sẽ hoàn số lượng tồn kho.
