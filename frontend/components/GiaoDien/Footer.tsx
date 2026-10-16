import Link from "next/link";
import { LockKeyhole, ShieldCheck, Truck } from "lucide-react";

const trustBadges = [
  { icon: LockKeyhole, title: "Thanh toán an toàn", detail: "Bảo mật SSL 256-bit" },
  { icon: ShieldCheck, title: "Chính hãng 100%", detail: "Nguồn gốc rõ ràng" },
  { icon: Truck, title: "Giao hàng tận tâm", detail: "Theo dõi đơn dễ dàng" },
];

export function Footer() {
  return (
    <footer className="mt-16 border-t border-rose-100 bg-[#fff5f2]">
      <div className="container grid gap-10 py-10 sm:grid-cols-2 lg:grid-cols-[1.3fr_1fr_1fr]">
        <div>
          <Link href="/" className="text-lg font-bold tracking-[0.14em] text-rose-900">THANH TÂM.</Link>
          <p className="mt-3 max-w-sm text-sm leading-6 text-stone-600">Chăm sóc vẻ đẹp mỗi ngày với những sản phẩm mỹ phẩm chính hãng được chọn lọc dành cho bạn.</p>
        </div>
        <div>
          <h2 className="font-semibold text-stone-900">Hỗ trợ khách hàng</h2>
          <ul className="mt-3 space-y-2 text-sm text-stone-600">
            <li><Link className="hover:text-rose-800" href="/chinh-sach/van-chuyen">Chính sách giao hàng</Link></li>
            <li><Link className="hover:text-rose-800" href="/chinh-sach/doi-tra">Đổi trả &amp; hoàn tiền</Link></li>
            <li><Link className="hover:text-rose-800" href="/chinh-sach/bao-mat">Chính sách bảo mật</Link></li>
          </ul>
        </div>
        <div>
          <h2 className="font-semibold text-stone-900">Mua sắm an tâm</h2>
          <div className="mt-3 grid gap-3 sm:grid-cols-1">
            {trustBadges.map(({ icon: Icon, title, detail }) => (
              <div className="flex items-center gap-3" key={title}>
                <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-white text-rose-800 shadow-sm"><Icon size={18} aria-hidden="true" /></span>
                <div><p className="text-sm font-semibold text-stone-800">{title}</p><p className="text-xs text-stone-500">{detail}</p></div>
              </div>
            ))}
          </div>
        </div>
      </div>
      <div className="border-t border-rose-100 py-4 text-center text-xs text-stone-500">© {new Date().getFullYear()} Thanh Tâm Cosmetics. All rights reserved.</div>
    </footer>
  );
}
