"use client";

import { useRef } from "react";
import { ArrowLeft, ArrowRight } from "lucide-react";
import type { SanPhamNoiBat } from "@/lib/products";
import { ProductCard } from "@/components/SanPham/ProductCard";
import { Button } from "@/components/SanPham/Button";

export function ProductCarousel({ products }: { products: SanPhamNoiBat[] }) {
  const trackRef = useRef<HTMLDivElement>(null);

  function scroll(direction: -1 | 1) {
    const track = trackRef.current;
    if (!track) return;
    track.scrollBy({ left: direction * track.clientWidth * 0.82, behavior: "smooth" });
  }

  return (
    <section aria-label="Sản phẩm nổi bật">
      <div className="mb-6 flex items-end justify-between gap-4">
        <div>
          <p className="mb-2 text-xs font-bold tracking-[0.2em] text-rose-700">ĐƯỢC YÊU THÍCH</p>
          <h2 className="text-2xl font-semibold text-stone-900 sm:text-3xl">Sản phẩm nổi bật</h2>
        </div>
        <div className="hidden gap-2 sm:flex">
          <Button variant="secondary" className="h-11 w-11 !p-0" onClick={() => scroll(-1)} aria-label="Sản phẩm trước">
            <ArrowLeft size={18} aria-hidden="true" />
          </Button>
          <Button variant="secondary" className="h-11 w-11 !p-0" onClick={() => scroll(1)} aria-label="Sản phẩm tiếp theo">
            <ArrowRight size={18} aria-hidden="true" />
          </Button>
        </div>
      </div>
      <div
        ref={trackRef}
        className="grid auto-cols-[minmax(72%,1fr)] grid-flow-col gap-4 overflow-x-auto scroll-smooth pb-4 snap-x snap-mandatory sm:auto-cols-[minmax(42%,1fr)] sm:gap-5 lg:auto-cols-[minmax(24%,1fr)]"
      >
        {products.map((product) => (
          <div className="snap-start" key={product.MaSanPham}>
            <ProductCard product={product} />
          </div>
        ))}
      </div>
    </section>
  );
}
