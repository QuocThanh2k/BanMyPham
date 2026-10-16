"use client";

import { getSession, signIn } from "next-auth/react";
import { FormEvent, useState } from "react";
import { ArrowRight, Eye, EyeOff, LockKeyhole, Sparkles, UserRound } from "lucide-react";

type AuthMode = "login" | "register";

function getCallbackUrl() {
  const requestedCallback = new URLSearchParams(window.location.search).get("callbackUrl");
  return requestedCallback?.startsWith("/")
    && !requestedCallback.startsWith("//")
    && !requestedCallback.startsWith("/\\")
    ? requestedCallback
    : null;
}

export function LoginForm() {
  const [mode, setMode] = useState<AuthMode>("login");
  const [error, setError] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [showPassword, setShowPassword] = useState(false);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError("");
    setIsSubmitting(true);
    const formData = new FormData(event.currentTarget);
    const email = String(formData.get("email") || "").trim();
    const password = String(formData.get("password") || "");

    try {
      if (mode === "register") {
        const fullName = String(formData.get("fullName") || "").trim();
        const phone = String(formData.get("phone") || "").trim();
        const confirmPassword = String(formData.get("confirmPassword") || "");
        if (password !== confirmPassword) {
          setError("Mật khẩu xác nhận chưa khớp.");
          return;
        }

        const response = await fetch("/api/account/register", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ fullName, email, phone, password }),
        });
        const result = await response.json();
        if (!response.ok) {
          setError(result.error || "Không thể tạo tài khoản. Vui lòng thử lại.");
          return;
        }
      }

      const callbackUrl = getCallbackUrl();
      const result = await signIn("credentials", {
        email,
        password,
        callbackUrl: callbackUrl || "/",
        redirect: false,
      });
      if (result?.error) {
        setError(mode === "register"
          ? "Tài khoản đã được tạo nhưng chưa thể đăng nhập. Vui lòng đăng nhập lại."
          : "Email hoặc mật khẩu không chính xác.");
        if (mode === "register") setMode("login");
        return;
      }
      const session = await getSession();
      const isAdmin = session?.user?.role === "admin" || session?.user?.role === "super_admin";
      const destination = callbackUrl === "/quan-tri" && !isAdmin
        ? "/ho-so"
        : callbackUrl || (isAdmin ? "/quan-tri" : "/ho-so");
      window.location.assign(destination);
    } catch (submitError) {
      console.error("Không thể hoàn tất yêu cầu tài khoản:", submitError);
      setError("Không thể kết nối máy chủ. Vui lòng thử lại sau.");
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <div className="mx-auto grid w-full max-w-5xl overflow-hidden rounded-[28px] border border-rose-100 bg-white shadow-[0_24px_80px_rgba(84,43,50,0.12)] lg:grid-cols-[0.9fr_1.1fr]">
      <div className="relative hidden overflow-hidden bg-gradient-to-br from-rose-900 via-rose-800 to-[#bd6879] p-10 text-white lg:flex lg:flex-col lg:justify-between">
        <div className="pointer-events-none absolute -right-24 -top-16 h-72 w-72 rounded-full border border-white/15" />
        <div className="pointer-events-none absolute -right-10 -top-2 h-44 w-44 rounded-full border border-white/15" />
        <div className="relative">
          <div className="mb-10 flex h-12 w-12 items-center justify-center rounded-2xl border border-white/25 bg-white/10">
            <Sparkles size={22} aria-hidden="true" />
          </div>
          <p className="text-xs font-semibold tracking-[0.24em] text-rose-100">THANH TÂM COSMETICS</p>
          <h2 className="mt-4 max-w-sm text-3xl font-semibold leading-tight tracking-tight">
            Nâng niu vẻ đẹp của bạn, bắt đầu từ hôm nay.
          </h2>
          <p className="mt-4 max-w-sm text-sm leading-7 text-rose-100">
            Đăng nhập để lưu lại sản phẩm yêu thích và quản lý thông tin tài khoản của bạn.
          </p>
        </div>
        <p className="relative text-xs text-rose-100">Chăm sóc vẻ đẹp mỗi ngày, theo cách của riêng bạn.</p>
      </div>

      <div className="p-5 sm:p-8 lg:p-10">
        <div className="mb-7">
          <p className="mb-2 text-xs font-bold tracking-[0.2em] text-rose-700 lg:hidden">THANH TÂM COSMETICS</p>
          <h1 className="text-2xl font-semibold tracking-tight text-stone-900 sm:text-3xl">
            {mode === "login" ? "Chào mừng bạn trở lại" : "Tạo tài khoản mới"}
          </h1>
          <p className="mt-2 text-sm leading-6 text-stone-600">
            {mode === "login"
              ? "Đăng nhập để tiếp tục trải nghiệm mua sắm cùng Thanh Tâm."
              : "Tham gia Thanh Tâm để bắt đầu hành trình chăm sóc sắc đẹp."}
          </p>
        </div>

        <div className="mb-6 grid grid-cols-2 rounded-xl bg-rose-50 p-1" role="tablist" aria-label="Chọn đăng nhập hoặc đăng ký">
          <button
            type="button"
            role="tab"
            aria-selected={mode === "login"}
            className={`flex min-h-11 items-center justify-center gap-2 rounded-lg px-3 text-sm font-semibold transition ${mode === "login" ? "bg-white text-rose-900 shadow-sm" : "text-stone-600 hover:text-rose-800"}`}
            onClick={() => { setMode("login"); setError(""); }}
          >
            <UserRound size={16} aria-hidden="true" /> Đăng nhập
          </button>
          <button
            type="button"
            role="tab"
            aria-selected={mode === "register"}
            className={`flex min-h-11 items-center justify-center gap-2 rounded-lg px-3 text-sm font-semibold transition ${mode === "register" ? "bg-white text-rose-900 shadow-sm" : "text-stone-600 hover:text-rose-800"}`}
            onClick={() => { setMode("register"); setError(""); }}
          >
            <Sparkles size={16} aria-hidden="true" /> Đăng ký
          </button>
        </div>

        <form className="grid gap-4" onSubmit={handleSubmit}>
          {mode === "register" && (
            <>
              <label className="form-field" htmlFor="account-name">
                Họ và tên
                <input id="account-name" name="fullName" required maxLength={150} autoComplete="name" placeholder="Nguyễn Văn A" />
              </label>
              <label className="form-field" htmlFor="account-phone">
                Số điện thoại <span className="font-normal text-stone-400">(không bắt buộc)</span>
                <input id="account-phone" name="phone" type="tel" inputMode="tel" maxLength={20} autoComplete="tel" placeholder="09xx xxx xxx" />
              </label>
            </>
          )}
          <label className="form-field" htmlFor="account-email">
            Email
            <input id="account-email" name="email" type="email" required maxLength={255} autoComplete="email" placeholder="ban@email.com" />
          </label>
          <label className="form-field" htmlFor="account-password">
            Mật khẩu
            <span className="relative">
              <input
                id="account-password"
                name="password"
                type={showPassword ? "text" : "password"}
                required
                minLength={mode === "register" ? 8 : 1}
                maxLength={128}
                autoComplete={mode === "register" ? "new-password" : "current-password"}
                placeholder={mode === "register" ? "Ít nhất 8 ký tự" : "Nhập mật khẩu của bạn"}
                className="pr-12"
              />
              <button
                type="button"
                className="absolute inset-y-0 right-0 flex w-12 items-center justify-center text-stone-500 hover:text-rose-800"
                onClick={() => setShowPassword((visible) => !visible)}
                aria-label={showPassword ? "Ẩn mật khẩu" : "Hiện mật khẩu"}
              >
                {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
              </button>
            </span>
          </label>
          {mode === "register" && (
            <label className="form-field" htmlFor="account-confirm-password">
              Xác nhận mật khẩu
              <input
                id="account-confirm-password"
                name="confirmPassword"
                type={showPassword ? "text" : "password"}
                required
                minLength={8}
                maxLength={128}
                autoComplete="new-password"
                placeholder="Nhập lại mật khẩu"
              />
            </label>
          )}
          {error && <p className="form-error" role="alert">{error}</p>}
          <button className="button mt-1 w-full" type="submit" disabled={isSubmitting}>
            {isSubmitting
              ? "Đang xử lý..."
              : mode === "login" ? "Đăng nhập" : "Tạo tài khoản"}
            {!isSubmitting && <ArrowRight size={17} aria-hidden="true" />}
          </button>
          <p className="flex items-center justify-center gap-1.5 text-xs text-stone-500">
            <LockKeyhole size={13} aria-hidden="true" />
            Thông tin tài khoản của bạn được bảo vệ an toàn.
          </p>
        </form>
      </div>
    </div>
  );
}
