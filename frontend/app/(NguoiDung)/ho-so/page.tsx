import { getServerSession } from "next-auth/next";
import { redirect } from "next/navigation";
import { CalendarDays, CheckCircle2, CircleUserRound, Mail, MapPin, Phone, ShieldCheck, UserRound } from "lucide-react";
import { SignOutButton } from "@/components/NguoiDung/SignOutButton";
import { authOptions } from "@/lib/auth";

function formatCreatedAt(value: string | null) {
  if (!value) return "Chưa có thông tin";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return "Chưa có thông tin";
  return new Intl.DateTimeFormat("vi-VN", {
    day: "2-digit",
    month: "long",
    year: "numeric",
  }).format(date);
}

export default async function ProfilePage() {
  const session = await getServerSession(authOptions);
  if (!session?.user) redirect("/dang-nhap?callbackUrl=%2Fho-so");

  const user = session.user;
  const initials = (user.name || user.email || "TT").trim().slice(0, 1).toUpperCase();
  const details = [
    { label: "Mã tài khoản", value: user.id || "Chưa có thông tin", icon: CircleUserRound },
    { label: "Họ và tên", value: user.name || "Chưa cập nhật", icon: UserRound },
    { label: "Email", value: user.email || "Chưa cập nhật", icon: Mail },
    { label: "Số điện thoại", value: user.phone || "Chưa cập nhật", icon: Phone },
    { label: "Địa chỉ", value: user.address?.trim() || "Chưa cập nhật", icon: MapPin },
    { label: "Ngày tạo tài khoản", value: formatCreatedAt(user.createdAt), icon: CalendarDays },
    { label: "Loại tài khoản", value: user.role === "super_admin" ? "Quản trị viên tổng" : user.role === "admin" ? "Quản trị viên" : "Khách hàng", icon: ShieldCheck },
  ];

  return (
    <section className="container section">
      <div className="mb-8 flex flex-col justify-between gap-5 sm:flex-row sm:items-end">
        <div>
          <p className="mb-2 text-xs font-bold tracking-[0.2em] text-rose-700">TÀI KHOẢN THANH TÂM</p>
          <h1 className="section-title mb-2">Thông tin tài khoản</h1>
          <p className="text-sm leading-6 text-stone-600">Quản lý và xem lại thông tin tài khoản của bạn.</p>
        </div>
        <SignOutButton />
      </div>

      <div className="mx-auto grid max-w-5xl gap-6 lg:grid-cols-[0.8fr_1.4fr]">
        <aside className="overflow-hidden rounded-3xl border border-rose-100 bg-white shadow-sm">
          <div className="h-24 bg-gradient-to-r from-rose-800 via-rose-700 to-[#c57c89]" />
          <div className="-mt-11 px-6 pb-6">
            <div className="flex h-20 w-20 items-center justify-center rounded-2xl border-4 border-white bg-rose-100 text-3xl font-semibold text-rose-900 shadow-sm" aria-hidden="true">
              {initials}
            </div>
            <h2 className="mt-4 break-words text-xl font-semibold text-stone-900">{user.name || "Tài khoản Thanh Tâm"}</h2>
            <p className="mt-1 break-all text-sm text-stone-600">{user.email}</p>
            <div className={`mt-5 inline-flex items-center gap-2 rounded-full px-3 py-1.5 text-xs font-semibold ${user.isActive ? "bg-emerald-50 text-emerald-800" : "bg-amber-50 text-amber-800"}`}>
              <CheckCircle2 size={14} aria-hidden="true" />
              {user.isActive ? "Tài khoản đang hoạt động" : "Tài khoản cần được kiểm tra"}
            </div>
            {user.mustResetPassword && (
              <p className="mt-4 rounded-xl bg-amber-50 p-3 text-sm leading-5 text-amber-900">
                Tài khoản cần đặt lại mật khẩu để tiếp tục sử dụng.
              </p>
            )}
            <p className="mt-6 border-t border-rose-100 pt-5 text-xs leading-5 text-stone-500">
              Vì lý do bảo mật, mật khẩu và dữ liệu xác thực không được hiển thị tại trang này.
            </p>
          </div>
        </aside>

        <div className="rounded-3xl border border-rose-100 bg-white p-5 shadow-sm sm:p-7">
          <div className="mb-5">
            <h2 className="text-lg font-semibold text-stone-900">Chi tiết hồ sơ</h2>
            <p className="mt-1 text-sm text-stone-600">Thông tin được lưu cùng tài khoản của bạn.</p>
          </div>
          <dl className="grid gap-3 sm:grid-cols-2">
            {details.map(({ label, value, icon: Icon }) => (
              <div key={label} className="min-w-0 rounded-2xl border border-rose-100/80 bg-rose-50/40 p-4">
                <dt className="flex items-center gap-2 text-xs font-semibold uppercase tracking-wide text-stone-500">
                  <Icon size={15} className="shrink-0 text-rose-700" aria-hidden="true" />
                  {label}
                </dt>
                <dd className="mt-2 break-words text-sm font-medium leading-6 text-stone-900">{value}</dd>
              </div>
            ))}
          </dl>
        </div>
      </div>
    </section>
  );
}
