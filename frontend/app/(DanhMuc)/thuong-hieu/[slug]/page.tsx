import { notFound } from "next/navigation";
import { ProductCard } from "@/components/SanPham/ProductCard";
import { getProducts } from "@/lib/products";

const brands: Record<string, string> = {
  laneige: "Laneige",
  innisfree: "Innisfree",
  mac: "MAC",
  dior: "Dior",
  theordinary: "The Ordinary",
  larocheposay: "La Roche-Posay",
  cocoon: "Cocoon",
  garnier: "Garnier",
  ysl: "Yves Saint Laurent",
  chanel: "Chanel",
};

type Props = { params: { slug: string } };

export default async function BrandProductsPage({ params }: Props) {
  const brandName = brands[params.slug];
  if (!brandName) notFound();

  const products = await getProducts(100, undefined, { brandSlug: params.slug });
  return (
    <section className="container py-12 sm:py-16">
      <p className="text-xs font-bold tracking-[0.2em] text-rose-700">THƯƠNG HIỆU</p>
      <h1 className="mt-2 text-3xl font-semibold text-stone-900 sm:text-4xl">{brandName}</h1>
      {products.length > 0 ? (
        <div className="product-grid mt-8">
          {products.map((product) => <ProductCard key={product.MaSanPham} product={product} />)}
        </div>
      ) : <p className="mt-8 text-stone-600">Thương hiệu này hiện chưa có sản phẩm.</p>}
    </section>
  );
}
