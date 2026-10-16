"use client";

import { signOut } from "next-auth/react";
import { LogOut } from "lucide-react";
import { useState } from "react";

export function SignOutButton() {
  const [isSigningOut, setIsSigningOut] = useState(false);
  const [error, setError] = useState("");

  async function handleSignOut() {
    setIsSigningOut(true);
    setError("");
    try {
      const result = await signOut({ redirect: false });
      if (!result?.url) throw new Error("Không nhận được phản hồi đăng xuất.");
      window.location.replace("/");
    } catch (signOutError) {
      console.error("Không thể đăng xuất:", signOutError);
      setError("Đăng xuất chưa thành công. Vui lòng tải lại trang và thử lại.");
      setIsSigningOut(false);
    }
  }

  return (
    <div>
      <button className="inline-flex min-h-10 items-center justify-center gap-2 rounded-full border border-rose-200 bg-white px-4 text-sm font-semibold text-rose-800 transition hover:bg-rose-50 disabled:cursor-wait disabled:opacity-60" type="button" disabled={isSigningOut} onClick={handleSignOut}>
        <LogOut size={16} aria-hidden="true" />
        {isSigningOut ? "Đang đăng xuất..." : "Đăng xuất"}
      </button>
      {error && <p role="alert" className="mt-2 text-xs text-red-700">{error}</p>}
    </div>
  );
}
