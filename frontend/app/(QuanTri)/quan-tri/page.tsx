"use client";

import { FormEvent, useCallback, useEffect, useMemo, useState } from "react";
import { getSession } from "next-auth/react";
import {
  Archive, ArrowRight, Boxes, CircleDollarSign, ClipboardList, Loader2,
  Pencil, Plus, RefreshCw, RotateCcw, ShieldCheck, ShoppingBag, Users, X,
} from "lucide-react";
import type { ReactNode } from "react";
import { api } from "@/lib/api";
import { SignOutButton } from "@/components/NguoiDung/SignOutButton";

type AdminRole = "customer" | "admin" | "super_admin";
type AdminTab = "overview" | "products" | "orders" | "users";
type CatalogOption = { id: number; name: string };
type Product = {
  id: number;
  name: string;
  slug: string;
  price: number;
  originalPrice: number | null;
  stock: number;
  imageUrl: string | null;
  categoryId: number | null;
  brandId: number | null;
  skinTypeId: number | null;
  description: string | null;
  expiresAt: string | null;
  isActive: boolean;
  categoryName: string | null;
  brandName: string | null;
};
type UserAccount = {
  id: number;
  fullName: string;
  email: string;
  phone: string | null;
  role: AdminRole;
  isActive: boolean;
  createdAt: string;
};
type Order = {
  id: number;
  status: "pending" | "confirmed" | "shipped" | "completed" | "cancelled";
  subtotal: number;
  shippingFee: number;
  total: number;
  paymentMethod: string;
  createdAt: string;
  itemCount: number;
};
type Overview = {
  activeProducts: number;
  lowStockProducts: number;
  customers: number;
  openOrders: number;
  totalOrders: number;
  revenue: number;
};
type ProductDraft = {
  name: string;
  slug: string;
  price: string;
  originalPrice: string;
  stock: string;
  imageUrl: string;
  categoryId: string;
  brandId: string;
  skinTypeId: string;
  description: string;
  expiresAt: string;
};

const EMPTY_DRAFT: ProductDraft = {
  name: "", slug: "", price: "", originalPrice: "", stock: "0",
  imageUrl: "", categoryId: "", brandId: "", skinTypeId: "",
  description: "", expiresAt: "",
};
const TABS: { id: AdminTab; label: string; icon: typeof Boxes }[] = [
  { id: "overview", label: "Tổng quan", icon: Boxes },
  { id: "products", label: "Sản phẩm", icon: ShoppingBag },
  { id: "orders", label: "Đơn hàng", icon: ClipboardList },
  { id: "users", label: "Tài khoản & quyền", icon: Users },
];
const STATUS_LABELS: Record<Order["status"], string> = {
  pending: "Chờ xác nhận",
  confirmed: "Đã xác nhận",
  shipped: "Đang giao",
  completed: "Hoàn tất",
  cancelled: "Đã hủy",
};
const STATUS_NEXT: Partial<Record<Order["status"], Order["status"][]>> = {
  pending: ["confirmed", "cancelled"],
  confirmed: ["shipped", "cancelled"],
  shipped: ["completed"],
};

function formatMoney(value: number) {
  return new Intl.NumberFormat("vi-VN", { style: "currency", currency: "VND" }).format(Number(value) || 0);
}

function formatDate(value: string) {
  return new Intl.DateTimeFormat("vi-VN", { dateStyle: "medium", timeStyle: "short" }).format(new Date(value));
}

function apiError(error: unknown) {
  if (typeof error === "object" && error !== null && "response" in error) {
    const response = (error as { response?: { data?: { error?: string } } }).response;
    if (response?.data?.error) return response.data.error;
  }
  return error instanceof Error ? error.message : "Đã xảy ra lỗi. Vui lòng thử lại.";
}

function slugify(value: string) {
  return value.normalize("NFD").replace(/[\u0300-\u036f]/g, "")
    .replace(/[đĐ]/g, "d").toLowerCase().trim()
    .replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
}

export default function AdminPage() {
  const [tab, setTab] = useState<AdminTab>("overview");
  const [role, setRole] = useState<AdminRole>("customer");
  const [overview, setOverview] = useState<Overview | null>(null);
  const [products, setProducts] = useState<Product[]>([]);
  const [orders, setOrders] = useState<Order[]>([]);
  const [users, setUsers] = useState<UserAccount[]>([]);
  const [catalog, setCatalog] = useState<{ categories: CatalogOption[]; brands: CatalogOption[]; skinTypes: CatalogOption[] }>({
    categories: [], brands: [], skinTypes: [],
  });
  const [draft, setDraft] = useState<ProductDraft>(EMPTY_DRAFT);
  const [productFormOpen, setProductFormOpen] = useState(false);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [search, setSearch] = useState("");
  const [showArchived, setShowArchived] = useState(false);
  const [error, setError] = useState("");
  const [notice, setNotice] = useState("");
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [busyIds, setBusyIds] = useState<number[]>([]);
  const [initialized, setInitialized] = useState(false);

  const loadData = useCallback(async (accessToken: string) => {
    const config = { headers: { Authorization: `Bearer ${accessToken}` } };
    const [summary, productList, orderList, userList, catalogOptions] = await Promise.all([
      api.get<{ data: Overview }>("/admin/overview", config),
      api.get<{ data: Product[] }>("/admin/products", config),
      api.get<{ data: Order[] }>("/admin/orders", config),
      api.get<{ data: UserAccount[] }>("/admin/users", config),
      api.get<{ data: typeof catalog }>("/admin/catalog-options", config),
    ]);
    setOverview(summary.data.data);
    setProducts(productList.data.data);
    setOrders(orderList.data.data);
    setUsers(userList.data.data);
    setCatalog(catalogOptions.data.data);
  }, []);

  useEffect(() => {
    let active = true;
    getSession().then(async (session) => {
      if (!active) return;
      const accessToken = session?.user?.backendToken;
      if (!accessToken) {
        setError("Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.");
        setLoading(false);
        return;
      }
      try {
        const currentUser = await api.get<{ data: { role: AdminRole } }>("/auth/me", {
          headers: { Authorization: `Bearer ${accessToken}` },
        });
        if (!["admin", "super_admin"].includes(currentUser.data.data.role)) {
          setError("Tài khoản của bạn chưa được cấp quyền quản trị.");
          setLoading(false);
          setInitialized(true);
          return;
        }
        setRole(currentUser.data.data.role);
        await loadData(accessToken);
      } catch (loadError) {
        if (active) setError(apiError(loadError));
      } finally {
        if (active) {
          setLoading(false);
          setInitialized(true);
        }
      }
    }).catch((sessionError: unknown) => {
      if (active) {
        setError(apiError(sessionError));
        setLoading(false);
      }
    });
    return () => { active = false; };
  }, [loadData]);

  const filteredProducts = useMemo(() => {
    const query = search.trim().toLocaleLowerCase("vi");
    return products.filter((product) => product.isActive !== showArchived
      && (!query || product.name.toLocaleLowerCase("vi").includes(query)
        || product.slug.toLocaleLowerCase("vi").includes(query)));
  }, [products, search, showArchived]);

  function clearFeedback() {
    setError("");
    setNotice("");
  }

  async function refresh() {
    clearFeedback();
    setLoading(true);
    const session = await getSession();
    if (!session?.user?.backendToken) {
      setError("Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.");
      setLoading(false);
      return;
    }
    try {
      await loadData(session.user.backendToken);
    } catch (refreshError) {
      setError(apiError(refreshError));
    } finally {
      setLoading(false);
    }
  }

  function openCreate() {
    clearFeedback();
    setEditingId(null);
    setDraft(EMPTY_DRAFT);
    setProductFormOpen(true);
  }

  function openEdit(product: Product) {
    clearFeedback();
    setEditingId(product.id);
    setProductFormOpen(true);
    setDraft({
      name: product.name,
      slug: product.slug,
      price: String(product.price),
      originalPrice: product.originalPrice === null ? "" : String(product.originalPrice),
      stock: String(product.stock),
      imageUrl: product.imageUrl || "",
      categoryId: product.categoryId ? String(product.categoryId) : "",
      brandId: product.brandId ? String(product.brandId) : "",
      skinTypeId: product.skinTypeId ? String(product.skinTypeId) : "",
      description: product.description || "",
      expiresAt: product.expiresAt ? product.expiresAt.slice(0, 10) : "",
    });
  }

  async function saveProduct(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    clearFeedback();
    setSaving(true);
    try {
      const session = await getSession();
      if (!session?.user?.backendToken) throw new Error("Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.");
      const payload = {
        ...draft,
        price: Number(draft.price),
        originalPrice: draft.originalPrice === "" ? null : Number(draft.originalPrice),
        stock: Number(draft.stock),
        categoryId: draft.categoryId || null,
        brandId: draft.brandId || null,
        skinTypeId: draft.skinTypeId || null,
        expiresAt: draft.expiresAt || null,
      };
      const config = { headers: { Authorization: `Bearer ${session.user.backendToken}` } };
      if (editingId) {
        await api.put(`/admin/products/${editingId}`, payload, config);
      } else {
        await api.post("/admin/products", payload, config);
      }
      setNotice(editingId ? "Đã cập nhật sản phẩm." : "Đã thêm sản phẩm mới.");
      setEditingId(null);
      setProductFormOpen(false);
      await loadData(session.user.backendToken);
    } catch (saveError) {
      setError(apiError(saveError));
    } finally {
      setSaving(false);
    }
  }

  async function archiveProduct(product: Product) {
    if (!window.confirm(`Ẩn sản phẩm “${product.name}” khỏi cửa hàng?`)) return;
    clearFeedback();
    try {
      const session = await getSession();
      if (!session?.user?.backendToken) throw new Error("Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.");
      await api.delete(`/admin/products/${product.id}`, {
        headers: { Authorization: `Bearer ${session.user.backendToken}` },
      });
      setProducts((current) => current.filter((item) => item.id !== product.id));
      setNotice("Đã ẩn sản phẩm khỏi cửa hàng.");
      if (overview) setOverview({ ...overview, activeProducts: Math.max(0, overview.activeProducts - 1) });
    } catch (archiveError) {
      setError(apiError(archiveError));
    }
  }

  async function restoreProduct(product: Product) {
    clearFeedback();
    try {
      const session = await getSession();
      if (!session?.user?.backendToken) throw new Error("Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.");
      await api.patch(`/admin/products/${product.id}/restore`, {}, {
        headers: { Authorization: `Bearer ${session.user.backendToken}` },
      });
      setProducts((current) => current.map((item) => item.id === product.id ? { ...item, isActive: true } : item));
      setNotice("Đã khôi phục sản phẩm.");
      if (overview) setOverview({ ...overview, activeProducts: overview.activeProducts + 1 });
    } catch (restoreError) {
      setError(apiError(restoreError));
    }
  }

  async function updateAccount(id: number, changes: Partial<Pick<UserAccount, "role" | "isActive">>) {
    clearFeedback();
    setBusyIds((current) => [...current, id]);
    try {
      const session = await getSession();
      if (!session?.user?.backendToken) throw new Error("Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.");
      const response = await api.patch<{ data: UserAccount }>(`/admin/users/${id}`, changes, {
        headers: { Authorization: `Bearer ${session.user.backendToken}` },
      });
      setUsers((current) => current.map((user) => user.id === id ? { ...user, ...response.data.data } : user));
      setNotice("Đã cập nhật tài khoản và quyền truy cập.");
    } catch (updateError) {
      setError(apiError(updateError));
      await refresh();
    } finally {
      setBusyIds((current) => current.filter((busyId) => busyId !== id));
    }
  }

  async function updateOrder(order: Order, status: Order["status"]) {
    clearFeedback();
    setBusyIds((current) => [...current, order.id]);
    try {
      const session = await getSession();
      if (!session?.user?.backendToken) throw new Error("Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.");
      await api.patch(`/admin/orders/${order.id}/status`, { status }, {
        headers: { Authorization: `Bearer ${session.user.backendToken}` },
      });
      setOrders((current) => current.map((item) => item.id === order.id ? { ...item, status } : item));
      setNotice(`Đã cập nhật trạng thái đơn #${order.id}.`);
    } catch (updateError) {
      setError(apiError(updateError));
    } finally {
      setBusyIds((current) => current.filter((busyId) => busyId !== order.id));
    }
  }

  if (loading && !initialized) {
    return <section className="container section"><div className="flex min-h-64 items-center justify-center gap-3 text-stone-600"><Loader2 className="animate-spin" />Đang tải trang quản trị...</div></section>;
  }

  return (
    <section className="container section max-w-[1400px]">
      <div className="mb-8 flex flex-wrap items-end justify-between gap-4">
        <div>
          <p className="mb-2 flex items-center gap-2 text-sm font-semibold uppercase tracking-[0.16em] text-rose-700">
            <ShieldCheck size={17} /> Khu vực bảo mật
          </p>
          <h1 className="text-3xl font-bold tracking-tight text-stone-900 sm:text-4xl">Quản trị cửa hàng</h1>
          <p className="mt-2 text-stone-600">{role === "super_admin" ? "Quản trị viên tổng" : "Quản trị viên"} · Quản lý cửa hàng và tài khoản</p>
        </div>
        <div className="flex items-center gap-2">
          <button type="button" onClick={refresh} className="inline-flex min-h-11 items-center gap-2 rounded-xl border border-rose-200 bg-white px-4 font-semibold text-rose-800 hover:bg-rose-50">
            <RefreshCw size={17} className={loading ? "animate-spin" : ""} /> Làm mới dữ liệu
          </button>
          <SignOutButton />
        </div>
      </div>

      {(error || notice) && (
        <div role="status" className={`mb-5 flex items-start justify-between gap-4 rounded-xl px-4 py-3 text-sm ${error ? "bg-red-50 text-red-800" : "bg-emerald-50 text-emerald-800"}`}>
          <span>{error || notice}</span>
          <button type="button" aria-label="Đóng thông báo" onClick={clearFeedback}><X size={18} /></button>
        </div>
      )}

      <div className="mb-7 flex gap-2 overflow-x-auto border-b border-rose-100 pb-2">
        {TABS.map(({ id, label, icon: Icon }) => (
          <button key={id} type="button" onClick={() => { setTab(id); clearFeedback(); }}
            className={`inline-flex shrink-0 items-center gap-2 rounded-xl px-4 py-3 text-sm font-semibold transition ${tab === id ? "bg-rose-800 text-white" : "text-stone-600 hover:bg-rose-50 hover:text-rose-900"}`}>
            <Icon size={17} /> {label}
          </button>
        ))}
      </div>

      {tab === "overview" && overview && (
        <div>
          <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
            <SummaryCard icon={ShoppingBag} label="Sản phẩm đang bán" value={overview.activeProducts} tone="rose" />
            <SummaryCard icon={ClipboardList} label="Đơn cần xử lý" value={overview.openOrders} tone="amber" />
            <SummaryCard icon={Users} label="Khách hàng" value={overview.customers} tone="blue" />
            <SummaryCard icon={CircleDollarSign} label="Doanh thu không gồm đơn hủy" value={formatMoney(Number(overview.revenue))} tone="green" />
          </div>
          <div className="mt-6 grid gap-5 lg:grid-cols-2">
            <div className="rounded-2xl border border-rose-100 bg-white p-5 shadow-sm">
              <h2 className="text-lg font-bold">Tình hình kho & đơn hàng</h2>
              <div className="mt-4 grid grid-cols-2 gap-3">
                <MiniStat label="Sắp hết hàng (≤ 5)" value={overview.lowStockProducts} />
                <MiniStat label="Tổng đơn hàng" value={overview.totalOrders} />
              </div>
            </div>
            <button type="button" onClick={() => setTab("orders")} className="group rounded-2xl border border-rose-100 bg-gradient-to-br from-rose-50 to-white p-5 text-left">
              <span className="flex items-center justify-between font-bold text-rose-950">Cần xử lý đơn hàng <ArrowRight size={18} className="transition group-hover:translate-x-1" /></span>
              <span className="mt-2 block text-sm text-stone-600">{overview.openOrders} đơn đang chờ xác nhận hoặc giao hàng.</span>
            </button>
          </div>
        </div>
      )}

      {tab === "products" && (
        <div>
          <div className="mb-5 flex flex-wrap items-center justify-between gap-3">
            <div>
              <h2 className="text-xl font-bold">Kho sản phẩm</h2>
              <p className="mt-1 text-sm text-stone-600">{filteredProducts.length} sản phẩm {showArchived ? "đã ẩn" : "đang bán"}</p>
            </div>
            <div className="flex flex-wrap gap-2">
              <button type="button" onClick={() => setShowArchived((value) => !value)} className="inline-flex min-h-11 items-center gap-2 rounded-xl border border-rose-200 bg-white px-4 font-semibold text-rose-900 hover:bg-rose-50"><Archive size={17} /> {showArchived ? "Xem đang bán" : `Đã ẩn (${products.filter((product) => !product.isActive).length})`}</button>
              {!showArchived && <button type="button" onClick={openCreate} className="inline-flex min-h-11 items-center gap-2 rounded-xl bg-rose-800 px-4 font-semibold text-white hover:bg-rose-900"><Plus size={18} /> Thêm sản phẩm</button>}
            </div>
          </div>
          <label className="mb-4 block max-w-md">
            <span className="sr-only">Tìm sản phẩm</span>
            <input value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Tìm theo tên hoặc đường dẫn..." className="min-h-11 w-full rounded-xl border border-rose-200 bg-white px-4 text-sm focus:border-rose-500 focus:outline-none" />
          </label>
          <div className="overflow-x-auto rounded-2xl border border-rose-100 bg-white shadow-sm">
            <table className="w-full min-w-[780px] text-left text-sm">
              <thead className="bg-rose-50 text-xs uppercase tracking-wide text-rose-950">
                <tr><th className="px-4 py-3">Sản phẩm</th><th className="px-4 py-3">Danh mục / thương hiệu</th><th className="px-4 py-3">Giá bán</th><th className="px-4 py-3">Tồn kho</th><th className="px-4 py-3 text-right">Thao tác</th></tr>
              </thead>
              <tbody className="divide-y divide-rose-50">
                {filteredProducts.map((product) => (
                  <tr key={product.id} className="hover:bg-rose-50/40">
                    <td className="px-4 py-3"><p className="font-semibold text-stone-900">{product.name}</p><p className="mt-1 text-xs text-stone-500">/{product.slug}</p></td>
                    <td className="px-4 py-3 text-stone-600">{product.categoryName || "Chưa phân loại"}<br /><span className="text-xs">{product.brandName || "—"}</span></td>
                    <td className="whitespace-nowrap px-4 py-3 font-semibold">{formatMoney(Number(product.price))}</td>
                    <td className="px-4 py-3"><span className={product.stock <= 5 ? "font-semibold text-amber-700" : "text-stone-700"}>{product.stock}</span></td>
                    <td className="px-4 py-3"><div className="flex justify-end gap-2">
                      {product.isActive
                        ? <><button type="button" onClick={() => openEdit(product)} aria-label={`Sửa ${product.name}`} className="rounded-lg border border-stone-200 p-2 text-stone-700 hover:bg-stone-50"><Pencil size={16} /></button>
                          <button type="button" onClick={() => archiveProduct(product)} aria-label={`Ẩn ${product.name}`} className="rounded-lg border border-red-100 p-2 text-red-700 hover:bg-red-50"><Archive size={16} /></button></>
                        : <button type="button" onClick={() => restoreProduct(product)} aria-label={`Khôi phục ${product.name}`} className="rounded-lg border border-emerald-100 p-2 text-emerald-800 hover:bg-emerald-50"><RotateCcw size={16} /></button>}
                    </div></td>
                  </tr>
                ))}
                {filteredProducts.length === 0 && <tr><td colSpan={5} className="px-4 py-12 text-center text-stone-500">Không tìm thấy sản phẩm phù hợp.</td></tr>}
              </tbody>
            </table>
          </div>
          {productFormOpen ? (
            <div className="fixed inset-0 z-50 flex items-center justify-center overflow-y-auto bg-stone-950/50 p-3 sm:p-6" role="dialog" aria-modal="true" aria-labelledby="product-dialog-title">
              <form onSubmit={saveProduct} className="max-h-[92vh] w-full max-w-3xl overflow-y-auto rounded-2xl bg-white p-5 shadow-2xl sm:p-7">
                <div className="mb-5 flex items-start justify-between">
                  <div><h3 id="product-dialog-title" className="text-xl font-bold">{editingId ? "Chỉnh sửa sản phẩm" : "Thêm sản phẩm"}</h3><p className="mt-1 text-sm text-stone-600">Các trường có dấu * là bắt buộc.</p></div>
                  <button type="button" onClick={() => { setEditingId(null); setDraft(EMPTY_DRAFT); setProductFormOpen(false); }} aria-label="Đóng" className="rounded-lg p-2 hover:bg-stone-100"><X size={20} /></button>
                </div>
                <div className="grid gap-4 sm:grid-cols-2">
                  <AdminField label="Tên sản phẩm *"><input required maxLength={255} value={draft.name} onChange={(event) => setDraft((current) => ({ ...current, name: event.target.value, slug: current.slug || slugify(event.target.value) }))} className="admin-input" /></AdminField>
                  <AdminField label="Đường dẫn (slug) *"><input required pattern="[a-z0-9]+(-[a-z0-9]+)*" maxLength={255} value={draft.slug} onChange={(event) => setDraft((current) => ({ ...current, slug: event.target.value }))} className="admin-input" /></AdminField>
                  <AdminField label="Giá bán (₫) *"><input required type="number" min="0" step="0.01" value={draft.price} onChange={(event) => setDraft((current) => ({ ...current, price: event.target.value }))} className="admin-input" /></AdminField>
                  <AdminField label="Giá gốc (₫)"><input type="number" min="0" step="0.01" value={draft.originalPrice} onChange={(event) => setDraft((current) => ({ ...current, originalPrice: event.target.value }))} className="admin-input" /></AdminField>
                  <AdminField label="Số lượng tồn kho *"><input required type="number" min="0" step="1" value={draft.stock} onChange={(event) => setDraft((current) => ({ ...current, stock: event.target.value }))} className="admin-input" /></AdminField>
                  <AdminField label="Hạn sử dụng"><input type="date" value={draft.expiresAt} onChange={(event) => setDraft((current) => ({ ...current, expiresAt: event.target.value }))} className="admin-input" /></AdminField>
                  <AdminField label="Danh mục"><select value={draft.categoryId} onChange={(event) => setDraft((current) => ({ ...current, categoryId: event.target.value }))} className="admin-input"><option value="">Chưa phân loại</option>{catalog.categories.map((option) => <option key={option.id} value={option.id}>{option.name}</option>)}</select></AdminField>
                  <AdminField label="Thương hiệu"><select value={draft.brandId} onChange={(event) => setDraft((current) => ({ ...current, brandId: event.target.value }))} className="admin-input"><option value="">Chưa chọn</option>{catalog.brands.map((option) => <option key={option.id} value={option.id}>{option.name}</option>)}</select></AdminField>
                  <AdminField label="Loại da"><select value={draft.skinTypeId} onChange={(event) => setDraft((current) => ({ ...current, skinTypeId: event.target.value }))} className="admin-input"><option value="">Chưa chọn</option>{catalog.skinTypes.map((option) => <option key={option.id} value={option.id}>{option.name}</option>)}</select></AdminField>
                  <AdminField label="Đường dẫn ảnh"><input type="text" maxLength={2048} value={draft.imageUrl} onChange={(event) => setDraft((current) => ({ ...current, imageUrl: event.target.value }))} placeholder="https://... hoặc /images/..." className="admin-input" /></AdminField>
                  <div className="sm:col-span-2"><AdminField label="Mô tả"><textarea maxLength={10000} rows={4} value={draft.description} onChange={(event) => setDraft((current) => ({ ...current, description: event.target.value }))} className="admin-input" /></AdminField></div>
                </div>
                {error && <p role="alert" className="mt-4 rounded-lg bg-red-50 p-3 text-sm text-red-800">{error}</p>}
                <div className="mt-5 flex justify-end gap-3">
                  <button type="button" onClick={() => { setEditingId(null); setDraft(EMPTY_DRAFT); setProductFormOpen(false); }} className="min-h-11 rounded-xl border border-stone-200 px-4 font-semibold">Hủy</button>
                  <button disabled={saving} className="inline-flex min-h-11 items-center gap-2 rounded-xl bg-rose-800 px-5 font-semibold text-white disabled:opacity-60">{saving && <Loader2 size={16} className="animate-spin" />}{editingId ? "Lưu thay đổi" : "Tạo sản phẩm"}</button>
                </div>
              </form>
            </div>
          ) : null}
        </div>
      )}

      {tab === "orders" && (
        <div>
          <div className="mb-5"><h2 className="text-xl font-bold">Quản lý đơn hàng</h2><p className="mt-1 text-sm text-stone-600">Trạng thái đơn được chuyển theo đúng quy trình; hủy đơn sẽ hoàn tồn kho.</p></div>
          <div className="overflow-x-auto rounded-2xl border border-rose-100 bg-white shadow-sm">
            <table className="w-full min-w-[850px] text-left text-sm">
              <thead className="bg-rose-50 text-xs uppercase tracking-wide text-rose-950"><tr><th className="px-4 py-3">Mã đơn</th><th className="px-4 py-3">Ngày đặt</th><th className="px-4 py-3">Sản phẩm</th><th className="px-4 py-3">Thanh toán</th><th className="px-4 py-3">Tổng tiền</th><th className="px-4 py-3">Trạng thái</th></tr></thead>
              <tbody className="divide-y divide-rose-50">
                {orders.map((order) => <tr key={order.id}>
                  <td className="px-4 py-3 font-semibold">#{order.id}</td><td className="whitespace-nowrap px-4 py-3">{formatDate(order.createdAt)}</td><td className="px-4 py-3">{order.itemCount} món</td><td className="px-4 py-3 uppercase">{order.paymentMethod}</td><td className="whitespace-nowrap px-4 py-3 font-semibold">{formatMoney(Number(order.total))}</td>
                  <td className="px-4 py-3"><div className="flex items-center gap-2"><span className="whitespace-nowrap">{STATUS_LABELS[order.status]}</span>{STATUS_NEXT[order.status] && <select aria-label={`Cập nhật trạng thái đơn ${order.id}`} disabled={busyIds.includes(order.id)} value="" onChange={(event) => { if (event.target.value) updateOrder(order, event.target.value as Order["status"]); }} className="max-w-36 rounded-lg border border-rose-200 bg-white px-2 py-2 text-xs"><option value="">Cập nhật...</option>{STATUS_NEXT[order.status]?.map((status) => <option key={status} value={status}>{STATUS_LABELS[status]}</option>)}</select>}</div></td>
                </tr>)}
                {orders.length === 0 && <tr><td colSpan={6} className="px-4 py-12 text-center text-stone-500">Chưa có đơn hàng.</td></tr>}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {tab === "users" && (
        <div>
          <div className="mb-5"><h2 className="text-xl font-bold">Tài khoản & phân quyền</h2><p className="mt-1 text-sm text-stone-600">Thứ bậc: Quản trị viên tổng → Quản trị viên → Khách hàng.</p></div>
          {role !== "super_admin" && <p className="mb-4 rounded-xl bg-amber-50 p-4 text-sm text-amber-900">Quản trị viên thường có thể khóa/mở tài khoản khách hàng; chỉ quản trị viên tổng mới được cấp hoặc thu hồi quyền quản trị viên.</p>}
          <div className="overflow-x-auto rounded-2xl border border-rose-100 bg-white shadow-sm">
            <table className="w-full min-w-[820px] text-left text-sm">
              <thead className="bg-rose-50 text-xs uppercase tracking-wide text-rose-950"><tr><th className="px-4 py-3">Tài khoản</th><th className="px-4 py-3">Ngày tạo</th><th className="px-4 py-3">Vai trò</th><th className="px-4 py-3">Trạng thái</th></tr></thead>
              <tbody className="divide-y divide-rose-50">
                {users.map((user) => <tr key={user.id}>
                  <td className="px-4 py-3"><p className="font-semibold">{user.fullName}</p><p className="mt-1 text-xs text-stone-500">{user.email}{user.phone ? ` · ${user.phone}` : ""}</p></td>
                  <td className="whitespace-nowrap px-4 py-3 text-stone-600">{formatDate(user.createdAt)}</td>
                  <td className="px-4 py-3">
                    {user.role === "super_admin" ? <span className="inline-flex items-center gap-1 rounded-full bg-rose-100 px-3 py-1.5 font-semibold text-rose-900"><ShieldCheck size={14} /> Tổng quản trị</span>
                      : role === "super_admin" ? <select disabled={busyIds.includes(user.id)} value={user.role} onChange={(event) => updateAccount(user.id, { role: event.target.value as AdminRole })} className="rounded-lg border border-stone-200 bg-white px-3 py-2"><option value="customer">Khách hàng</option><option value="admin">Quản trị viên</option></select>
                        : <span className="rounded-full bg-stone-100 px-3 py-1.5 font-medium">{user.role === "admin" ? "Quản trị viên" : "Khách hàng"}</span>}
                  </td>
                  <td className="px-4 py-3"><button type="button" disabled={user.role === "super_admin" || busyIds.includes(user.id)} onClick={() => updateAccount(user.id, { isActive: !user.isActive })} className={`rounded-full px-3 py-1.5 text-xs font-semibold disabled:cursor-not-allowed disabled:opacity-50 ${user.isActive ? "bg-emerald-50 text-emerald-800 hover:bg-emerald-100" : "bg-red-50 text-red-800 hover:bg-red-100"}`}>{user.isActive ? "Đang hoạt động" : "Đã khóa"}</button></td>
                </tr>)}
                {users.length === 0 && <tr><td colSpan={4} className="px-4 py-12 text-center text-stone-500">Chưa có tài khoản.</td></tr>}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </section>
  );
}

function SummaryCard({ icon: Icon, label, value, tone }: { icon: typeof Boxes; label: string; value: string | number; tone: "rose" | "amber" | "blue" | "green" }) {
  const tones = {
    rose: "bg-rose-100 text-rose-800",
    amber: "bg-amber-100 text-amber-800",
    blue: "bg-sky-100 text-sky-800",
    green: "bg-emerald-100 text-emerald-800",
  };
  return <div className="rounded-2xl border border-rose-100 bg-white p-5 shadow-sm"><span className={`inline-flex rounded-xl p-3 ${tones[tone]}`}><Icon size={20} /></span><p className="mt-4 text-sm text-stone-600">{label}</p><p className="mt-1 break-words text-2xl font-bold text-stone-900">{value}</p></div>;
}

function MiniStat({ label, value }: { label: string; value: number }) {
  return <div className="rounded-xl bg-stone-50 p-4"><p className="text-sm text-stone-600">{label}</p><p className="mt-1 text-2xl font-bold">{value}</p></div>;
}

function AdminField({ label, children }: { label: string; children: ReactNode }) {
  return <label className="grid gap-1.5 text-sm font-semibold text-stone-700">{label}{children}</label>;
}
