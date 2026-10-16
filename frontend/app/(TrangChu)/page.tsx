import Link from "next/link";
import { ArrowRight, Sparkles } from "lucide-react";
import { ProductCarousel } from "@/components/SanPham/ProductCarousel";
import { Button } from "@/components/SanPham/Button";
import { getFeaturedProducts } from "@/lib/products";

export default async function HomePage() {
  const products = await getFeaturedProducts();

  return (
    <>
      <section className="relative isolate overflow-hidden bg-gradient-to-br from-rose-50 via-[#fff8f4] to-orange-50">
        <div className="absolute inset-0 -z-10 opacity-25" style={{ backgroundImage: "radial-gradient(circle at 75% 40%, #d69a9c 0, transparent 34%)" }} />
        <div className="container grid min-h-[500px] items-center gap-10 py-16 md:grid-cols-[1.05fr_0.95fr] md:py-20">
          <div className="max-w-xl">
            <p className="mb-5 inline-flex items-center gap-2 rounded-full border border-rose-200 bg-white/70 px-4 py-2 text-xs font-semibold tracking-wider text-rose-800">
              <Sparkles size={15} aria-hidden="true" /> VẺ ĐẸP BẮT ĐẦU TỪ SỰ CHĂM SÓC
            </p>
            <h1 className="text-4xl font-semibold leading-tight tracking-tight text-stone-900 sm:text-5xl lg:text-6xl">
              Dịu dàng chăm da,<br /><span className="text-rose-800">rạng rỡ là chính mình.</span>
            </h1>
            <p className="mt-5 max-w-lg text-base leading-7 text-stone-600 sm:text-lg">
              Khám phá mỹ phẩm chính hãng được tuyển chọn để nâng niu làn da và biến mỗi ngày thành một trải nghiệm chăm sóc thật dễ chịu.
            </p>
            <div className="mt-8 flex flex-wrap gap-3">
              <Link href="/danh-muc/cham-soc-da" className="inline-flex min-h-11 items-center justify-center gap-2 rounded-full bg-rose-700 px-5 py-2.5 text-sm font-semibold text-white transition hover:bg-rose-800 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-rose-500 focus-visible:ring-offset-2">
                Khám phá sản phẩm <ArrowRight size={17} aria-hidden="true" />
              </Link>
              <Link href="#san-pham-noi-bat" className="inline-flex min-h-11 items-center justify-center rounded-full border border-rose-200 bg-white px-5 py-2.5 text-sm font-semibold text-rose-800 transition hover:bg-rose-50 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-rose-500 focus-visible:ring-offset-2">
                Xem sản phẩm nổi bật
              </Link>
            </div>
            <div className="mt-9 flex flex-wrap gap-x-6 gap-y-2 text-sm text-stone-600">
              <span>✓ Mỹ phẩm chính hãng</span><span>✓ Tư vấn tận tâm</span><span>✓ Giao hàng toàn quốc</span>
            </div>
          </div>
          <div className="relative mx-auto w-full max-w-lg">
            <div className="absolute -inset-4 rounded-[2rem] bg-gradient-to-br from-rose-200/60 to-orange-100/40 blur-2xl" />
            <div
              role="img"
              aria-label="Bộ mỹ phẩm chăm sóc da được tuyển chọn"
              className="relative aspect-[4/3] rounded-[2rem] border border-white/80 bg-rose-100 bg-cover bg-center shadow-2xl shadow-rose-900/10"
              style={{ backgroundImage: "url('https://images.unsplash.com/photo-1596462502278-27bfdc403348?auto=format&fit=crop&w=1200&q=90')" }}
            >
              <div className="absolute bottom-4 left-4 rounded-2xl border border-white/70 bg-white/90 px-4 py-3 shadow-lg backdrop-blur sm:bottom-6 sm:left-6">
                <p className="text-xs text-stone-500">Yêu thương làn da</p>
                <p className="mt-1 font-semibold text-stone-900">Bắt đầu từ hôm nay ✨</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section id="san-pham-noi-bat" className="container scroll-mt-24 py-14 sm:py-20">
        <ProductCarousel products={products} />
      </section>
    </>
  );
}
