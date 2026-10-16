export type SanPhamNoiBat = {
  MaSanPham: number;
  slug: string;
  TenSanPham: string;
  Gia: number;
  GiaGoc: number | null;
  LinkAnh: string;
  nhan: string;
  SoLuongKho: number;
  MoTa: string | null;
  DanhGia: number;
};

type ApiProduct = {
  id: number;
  slug: string;
  name: string;
  price: number;
  originalPrice: number | null;
  stock: number;
  description: string | null;
  imageUrl: string;
  rating: number;
};

function getApiBaseUrl() {
  return typeof window === "undefined"
    ? process.env.BACKEND_API_URL ?? process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:4000/api"
    : process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:4000/api";
}

export function getPublicImageUrl(imagePath: string) {
  return `${getApiBaseUrl().replace(/\/api\/?$/, "")}/${imagePath.replace(/^\/+/, "")}`;
}

function mapProduct(product: ApiProduct): SanPhamNoiBat {
  return {
    MaSanPham: product.id,
    slug: product.slug,
    TenSanPham: product.name,
    Gia: product.price,
    GiaGoc: product.originalPrice,
    LinkAnh: product.imageUrl,
    nhan: "ĐƯỢC YÊU THÍCH",
    SoLuongKho: product.stock,
    MoTa: product.description,
    DanhGia: product.rating,
  };
}

export async function getProducts(
  limit = 24,
  search?: string,
  filters: { categorySlug?: string; brandSlug?: string } = {},
): Promise<SanPhamNoiBat[]> {
  const params = new URLSearchParams({ limit: String(limit) });
  if (search) params.set("search", search);
  if (filters.categorySlug) params.set("categorySlug", filters.categorySlug);
  if (filters.brandSlug) params.set("brandSlug", filters.brandSlug);
  const response = await fetch(`${getApiBaseUrl()}/sanpham?${params}`, { cache: "no-store" });
  if (!response.ok) {
    throw new Error(`Không thể tải danh sách sản phẩm (HTTP ${response.status})`);
  }

  const payload = await response.json() as { data: ApiProduct[] };
  if (!Array.isArray(payload.data)) {
    throw new Error("API sản phẩm trả về dữ liệu không hợp lệ");
  }

  return payload.data.map(mapProduct);
}

export function getFeaturedProducts(): Promise<SanPhamNoiBat[]> {
  return getProducts(5);
}

export async function getProductBySlug(slug: string): Promise<SanPhamNoiBat | null> {
  const response = await fetch(
    `${getApiBaseUrl()}/sanpham/slug/${encodeURIComponent(slug)}`,
    { cache: "no-store" },
  );
  if (response.status === 404) return null;
  if (!response.ok) {
    throw new Error(`Không thể tải thông tin sản phẩm (HTTP ${response.status})`);
  }

  const payload = await response.json() as { data: ApiProduct };
  if (!payload.data) throw new Error("API sản phẩm trả về dữ liệu không hợp lệ");
  return mapProduct(payload.data);
}
