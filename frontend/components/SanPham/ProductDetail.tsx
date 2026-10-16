"use client";

import Link from "next/link";
import { Star } from "lucide-react";
import { AddToCartButton } from "@/components/SanPham/AddToCartButton";
import type { SanPhamNoiBat } from "@/lib/products";
import { formatCurrency } from "@/lib/format";

export function ProductDetail({ product }: { product: SanPhamNoiBat }) {
  return (
    <section className="container py-10 sm:py-16">
      <nav aria-label="Đường dẫn" className="mb-8 text-sm text-stone-500">
        <Link href="/" className="hover:text-rose-800">Trang chủ</Link>
        <span className="mx-2">/</span>
        <span>Sản phẩm</span>
      </nav>

      <div className="grid gap-8 lg:grid-cols-2 lg:gap-14">
        <div
          role="img"
          aria-label={product.TenSanPham}
          className="aspect-square rounded-3xl bg-rose-50 bg-contain bg-center bg-no-repeat"
          style={{ backgroundImage: `url("${product.LinkAnh}")` }}
        />

        <div className="flex flex-col justify-center">
          <p className="text-xs font-bold tracking-[0.2em] text-rose-700">THANH TÂM COSMETICS</p>
          <h1 className="mt-3 text-3xl font-semibold text-stone-900 sm:text-4xl">
            {product.TenSanPham}
          </h1>
          <p className="mt-4 flex items-center gap-2 text-sm text-stone-600">
            <Star size={17} className="fill-amber-400 text-amber-400" aria-hidden="true" />
            {product.DanhGia.toFixed(1)} / 5
          </p>

          <div className="mt-6 flex flex-wrap items-baseline gap-3">
            <span className="text-2xl font-bold text-rose-800">{formatCurrency(product.Gia)}</span>
            {product.GiaGoc !== null && (
              <span className="text-base text-stone-400 line-through">{formatCurrency(product.GiaGoc)}</span>
            )}
          </div>

          <p className="mt-5 leading-7 text-stone-600">
            {product.MoTa || "Sản phẩm chăm sóc sắc đẹp được tuyển chọn tại Thanh Tâm Cosmetics."}
          </p>
          <p className="mt-4 text-sm text-stone-600">
            {product.SoLuongKho > 0 ? `Còn ${product.SoLuongKho} sản phẩm` : "Tạm hết hàng"}
          </p>

          <AddToCartButton product={product} className="mt-7 w-full sm:w-fit" />
        </div>
      </div>
    </section>
  );
}
