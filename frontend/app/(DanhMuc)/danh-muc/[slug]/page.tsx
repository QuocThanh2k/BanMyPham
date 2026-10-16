import { ProductCard } from "@/components/SanPham/ProductCard";
import { getProducts } from "@/lib/products";
import { notFound } from "next/navigation";

type Props = { params: { slug: string } };

const categoryAliases: Record<string, { slug: string; name: string }> = {
  skincare: { slug: "skincare", name: "Chăm sóc da" },
  "cham-soc-da": { slug: "skincare", name: "Chăm sóc da" },
  makeup: { slug: "makeup", name: "Trang điểm" },
  "trang-diem": { slug: "makeup", name: "Trang điểm" },
  cleansing: { slug: "cleansing", name: "Làm sạch" },
  perfume: { slug: "perfume", name: "Nước hoa" },
  haircare: { slug: "haircare", name: "Chăm sóc tóc" },
};

export default async function CategoryPage({ params }: Props) {
  const category = categoryAliases[params.slug];
  if (!category) notFound();
  const products = await getProducts(100, undefined, { categorySlug: category.slug });
  return (
    <section className="container section">
      <p className="muted">Danh mục sản phẩm</p>
      <h1 className="section-title">{category.name}</h1>
      {products.length > 0 ? (
        <div className="product-grid">
          {products.map((product) => <ProductCard key={product.MaSanPham} product={product} />)}
        </div>
      ) : <p className="text-stone-600">Danh mục này hiện chưa có sản phẩm.</p>}
    </section>
  );
}
