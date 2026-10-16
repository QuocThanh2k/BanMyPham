import Link from "next/link";

const brands = [
  { slug: "laneige", name: "Laneige" },
  { slug: "innisfree", name: "Innisfree" },
  { slug: "mac", name: "MAC" },
  { slug: "dior", name: "Dior" },
  { slug: "theordinary", name: "The Ordinary" },
  { slug: "larocheposay", name: "La Roche-Posay" },
  { slug: "cocoon", name: "Cocoon" },
  { slug: "garnier", name: "Garnier" },
  { slug: "ysl", name: "Yves Saint Laurent" },
  { slug: "chanel", name: "Chanel" },
];

export default function BrandsPage() {
  return (
    <section className="container py-12 sm:py-16">
      <p className="text-xs font-bold tracking-[0.2em] text-rose-700">THƯƠNG HIỆU ĐƯỢC TUYỂN CHỌN</p>
      <h1 className="mt-2 text-3xl font-semibold text-stone-900 sm:text-4xl">Thương hiệu</h1>
      <div className="mt-8 grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-5">
        {brands.map((brand) => (
          <Link
            key={brand.slug}
            href={`/thuong-hieu/${brand.slug}`}
            className="flex min-h-28 items-center justify-center rounded-2xl border border-rose-100 bg-white p-5 text-center text-lg font-semibold text-stone-800 transition hover:border-rose-300 hover:bg-rose-50 hover:text-rose-800"
          >
            {brand.name}
          </Link>
        ))}
      </div>
    </section>
  );
}
