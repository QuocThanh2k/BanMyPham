"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { getSession } from "next-auth/react";
import { Search, ShieldCheck, ShoppingBag, UserRound, X } from "lucide-react";
import { getProducts, type SanPhamNoiBat } from "@/lib/products";
import { useAppSelector } from "@/store/hooks";

export function Header() {
  const [query, setQuery] = useState("");
  const [searchOpen, setSearchOpen] = useState(false);
  const [products, setProducts] = useState<SanPhamNoiBat[]>([]);
  const [searchLoading, setSearchLoading] = useState(false);
  const [searchError, setSearchError] = useState("");
  const [canManageStore, setCanManageStore] = useState(false);
  const cartCount = useAppSelector((state) =>
    state.gioHang.items.reduce((total, item) => total + item.quantity, 0),
  );

  useEffect(() => {
    const search = query.trim();
    if (!search) {
      setProducts([]);
      setSearchError("");
      setSearchLoading(false);
      return;
    }

    let cancelled = false;
    setProducts([]);
    setSearchLoading(true);
    setSearchError("");
    const timeout = window.setTimeout(() => {
      void getProducts(5, search)
        .then((results) => {
          if (!cancelled) setProducts(results);
        })
        .catch(() => {
          if (!cancelled) setSearchError("Không thể tải kết quả tìm kiếm. Vui lòng thử lại.");
        })
        .finally(() => {
          if (!cancelled) setSearchLoading(false);
        });
    }, 250);

    return () => {
      cancelled = true;
      window.clearTimeout(timeout);
    };
  }, [query]);

  useEffect(() => {
    let active = true;
    getSession().then((session) => {
      if (active) setCanManageStore(session?.user?.role === "admin" || session?.user?.role === "super_admin");
    });
    return () => { active = false; };
  }, []);

  const showResults = searchOpen && query.trim().length > 0;
  const searchMessage = searchError || (searchLoading
    ? "Đang tìm sản phẩm..."
    : products.length === 0 ? "Không tìm thấy sản phẩm phù hợp." : "");

  return (
    <header className="sticky top-0 z-40 border-b border-rose-100 bg-white/95 shadow-sm backdrop-blur">
      <div className="container">
        <div className="flex min-h-[72px] items-center justify-between gap-3">
          <Link href="/" className="shrink-0 text-lg font-bold tracking-[0.14em] text-rose-900 sm:text-xl" aria-label="Thanh Tâm Cosmetics - Trang chủ">
            THANH TÂM<span className="ml-1 text-rose-600">.</span>
          </Link>
          <nav className="hidden items-center gap-5 text-sm font-medium text-stone-700 xl:flex" aria-label="Điều hướng chính">
            <Link className="hover:text-rose-800" href="/danh-muc">Danh mục</Link>
            <Link className="hover:text-rose-800" href="/thuong-hieu">Thương hiệu</Link>
            <Link className="hover:text-rose-800" href="/blog">Blog</Link>
            <Link className="hover:text-rose-800" href="/lien-he">Liên hệ</Link>
          </nav>
          <div className="flex items-center gap-2 sm:gap-3">
            {canManageStore && <Link href="/quan-tri" aria-label="Trang quản trị" className="inline-flex items-center gap-1 rounded-full bg-rose-50 p-2 text-sm font-semibold text-rose-900 hover:bg-rose-100 sm:px-3"><ShieldCheck size={17} aria-hidden="true" /><span className="hidden sm:inline">Quản trị</span></Link>}
            <div
              className="relative hidden w-48 md:block lg:w-64"
              onBlur={(event) => {
                if (event.relatedTarget instanceof Node && event.currentTarget.contains(event.relatedTarget)) return;
                window.setTimeout(() => setSearchOpen(false), 150);
              }}
            >
              <label className="flex h-10 items-center gap-2 rounded-full border border-rose-100 bg-rose-50/60 px-3 focus-within:border-rose-400 focus-within:bg-white">
                <Search size={17} className="shrink-0 text-stone-500" aria-hidden="true" />
                <input
                  className="min-w-0 flex-1 bg-transparent text-sm outline-none placeholder:text-stone-400"
                  type="search"
                  value={query}
                  onChange={(event) => { setQuery(event.target.value); setSearchOpen(true); }}
                  onFocus={() => setSearchOpen(true)}
                  placeholder="Tìm sản phẩm..."
                  aria-label="Tìm kiếm sản phẩm"
                  aria-expanded={showResults}
                />
                {query && <button type="button" onMouseDown={(event) => event.preventDefault()} onClick={() => setQuery("")} aria-label="Xóa nội dung tìm kiếm"><X size={15} /></button>}
              </label>
              {showResults && (
                <div className="absolute right-0 top-12 w-72 overflow-hidden rounded-xl border border-rose-100 bg-white p-2 shadow-xl lg:w-80">
                  {products.length ? products.map((product) => (
                    <Link
                      key={product.MaSanPham}
                      href={`/san-pham/${product.slug}`}
                      className="block rounded-lg px-3 py-2 text-sm hover:bg-rose-50"
                      onClick={() => { setQuery(""); setSearchOpen(false); }}
                    >
                      {product.TenSanPham}
                    </Link>
                  )) : <p className="px-3 py-2 text-sm text-stone-500">{searchMessage}</p>}
                </div>
              )}
            </div>
            <button
              type="button"
              className="flex h-10 w-10 items-center justify-center rounded-full text-stone-700 hover:bg-rose-50 md:hidden"
              onClick={() => setSearchOpen((open) => !open)}
              aria-label={searchOpen ? "Đóng tìm kiếm" : "Mở tìm kiếm"}
            >
              {searchOpen ? <X size={20} /> : <Search size={20} />}
            </button>
            <Link href="/ho-so" className="flex h-10 w-10 items-center justify-center rounded-full text-stone-700 transition hover:bg-rose-50 hover:text-rose-800" aria-label="Tài khoản">
              <UserRound size={20} aria-hidden="true" />
            </Link>
            <Link href="/gio-hang" className="relative flex h-10 w-10 items-center justify-center rounded-full text-stone-700 hover:bg-rose-50" aria-label={`Giỏ hàng, ${cartCount} sản phẩm`}>
              <ShoppingBag size={21} aria-hidden="true" />
              {cartCount > 0 && <span className="absolute -right-0.5 -top-0.5 flex h-5 min-w-5 items-center justify-center rounded-full bg-rose-700 px-1 text-[10px] font-bold text-white">{cartCount > 99 ? "99+" : cartCount}</span>}
            </Link>
          </div>
        </div>
        <div className="pb-3 md:hidden" hidden={!searchOpen}>
          <label className="flex h-11 items-center gap-2 rounded-full border border-rose-200 bg-rose-50/60 px-4">
            <Search size={18} className="text-stone-500" aria-hidden="true" />
            <input
              className="min-w-0 flex-1 bg-transparent text-sm outline-none placeholder:text-stone-400"
              type="search"
              value={query}
              onChange={(event) => setQuery(event.target.value)}
              placeholder="Tìm sản phẩm..."
              aria-label="Tìm kiếm sản phẩm"
            />
          </label>
          {query.trim() && (
            <div className="mt-2 rounded-xl border border-rose-100 bg-white p-2 shadow-lg">
              {products.length ? products.map((product) => (
                <Link key={product.MaSanPham} href={`/san-pham/${product.slug}`} className="block rounded-lg px-3 py-2 text-sm hover:bg-rose-50" onClick={() => { setQuery(""); setSearchOpen(false); }}>
                  {product.TenSanPham}
                </Link>
              )) : <p className="px-3 py-2 text-sm text-stone-500">{searchMessage}</p>}
            </div>
          )}
        </div>
        <nav className="flex gap-6 overflow-x-auto border-t border-rose-100 py-3 text-sm font-medium text-stone-700 xl:hidden" aria-label="Điều hướng chính">
          <Link className="shrink-0 hover:text-rose-800" href="/danh-muc">Danh mục</Link>
          <Link className="shrink-0 hover:text-rose-800" href="/thuong-hieu">Thương hiệu</Link>
          <Link className="shrink-0 hover:text-rose-800" href="/blog">Blog</Link>
          <Link className="shrink-0 hover:text-rose-800" href="/lien-he">Liên hệ</Link>
        </nav>
      </div>
    </header>
  );
}
