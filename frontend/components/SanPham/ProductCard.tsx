"use client";

import Link from "next/link";
import { AddToCartButton } from "@/components/SanPham/AddToCartButton";
import type { SanPhamNoiBat } from "@/lib/products";
import { formatCurrency } from "@/lib/format";

export function ProductCard({ product }: { product: SanPhamNoiBat }) {
  return (
    <article className="group min-w-0 overflow-hidden rounded-2xl border border-rose-100 bg-white shadow-sm transition hover:-translate-y-1 hover:shadow-lg">
      <Link href={`/san-pham/${product.slug}`} className="block">
        <div
          role="img"
          aria-label={product.TenSanPham}
          className="relative aspect-[4/4.5] overflow-hidden bg-rose-50 bg-cover bg-center transition duration-500 group-hover:scale-[1.02]"
          style={{ backgroundImage: `url("${product.LinkAnh}")` }}
        >
          <span className="absolute left-3 top-3 rounded-full bg-white/90 px-3 py-1 text-[10px] font-bold tracking-wider text-rose-800">
            {product.nhan}
          </span>
        </div>
      </Link>
      <div className="p-4 sm:p-5">
        <Link href={`/san-pham/${product.slug}`} className="line-clamp-2 min-h-12 font-medium text-stone-800 hover:text-rose-800">
          {product.TenSanPham}
        </Link>
        <div className="mt-3 flex flex-wrap items-baseline gap-x-2 gap-y-1">
          <span className="font-bold text-rose-800">{formatCurrency(product.Gia)}</span>
          {product.GiaGoc !== null && (
            <span className="text-sm text-stone-400 line-through">{formatCurrency(product.GiaGoc)}</span>
          )}
        </div>
        <AddToCartButton product={product} className="mt-4 w-full" />
      </div>
    </article>
  );
}
