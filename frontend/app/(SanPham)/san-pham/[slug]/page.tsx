import { notFound } from "next/navigation";
import { ProductDetail } from "@/components/SanPham/ProductDetail";
import { getProductBySlug } from "@/lib/products";

type Props = { params: { slug: string } };

export default async function ProductDetailPage({ params }: Props) {
  const product = await getProductBySlug(params.slug);
  if (!product) notFound();
  return <ProductDetail product={product} />;
}
