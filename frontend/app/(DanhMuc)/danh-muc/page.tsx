import Link from "next/link";

const categories = [
  { slug: "skincare", name: "Chăm sóc da", description: "Sản phẩm dưỡng da hằng ngày." },
  { slug: "makeup", name: "Trang điểm", description: "Mỹ phẩm trang điểm cho nhiều phong cách." },
  { slug: "cleansing", name: "Làm sạch", description: "Sản phẩm làm sạch da." },
  { slug: "perfume", name: "Nước hoa", description: "Khám phá các dòng nước hoa." },
  { slug: "haircare", name: "Chăm sóc tóc", description: "Sản phẩm chăm sóc tóc." },
];

export default function CategoriesPage() {
  return (
    <section className="container py-12 sm:py-16">
      <p className="text-xs font-bold tracking-[0.2em] text-rose-700">KHÁM PHÁ SẢN PHẨM</p>
      <h1 className="mt-2 text-3xl font-semibold text-stone-900 sm:text-4xl">Danh mục sản phẩm</h1>
      <div className="mt-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {categories.map((category) => (
          <Link
            key={category.slug}
            href={`/danh-muc/${category.slug}`}
            className="rounded-2xl border border-rose-100 bg-white p-6 transition hover:-translate-y-1 hover:border-rose-300 hover:shadow-lg"
          >
            <h2 className="text-xl font-semibold text-stone-900">{category.name}</h2>
            <p className="mt-2 text-sm leading-6 text-stone-600">{category.description}</p>
            <span className="mt-5 inline-block text-sm font-semibold text-rose-800">Xem sản phẩm →</span>
          </Link>
        ))}
      </div>
    </section>
  );
}
