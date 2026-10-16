"use client";

import Link from "next/link";
import { Minus, Plus, Trash2 } from "lucide-react";
import { Button } from "@/components/SanPham/Button";
import { formatCurrency } from "@/lib/format";
import { clearCart, removeItem, updateQuantity } from "@/store/gioHangSlice";
import { useAppDispatch, useAppSelector } from "@/store/hooks";

export function CartContents() {
  const dispatch = useAppDispatch();
  const items = useAppSelector((state) => state.gioHang.items);
  const total = items.reduce((sum, item) => sum + item.unitPrice * item.quantity, 0);

  if (items.length === 0) {
    return (
      <div className="rounded-2xl border border-rose-100 bg-white px-6 py-12 text-center">
        <p className="text-lg font-medium text-stone-800">Giỏ hàng của bạn đang trống.</p>
        <Link href="/" className="mt-5 inline-flex min-h-11 items-center rounded-full bg-rose-700 px-5 py-2.5 text-sm font-semibold text-white hover:bg-rose-800">
          Tiếp tục mua sắm
        </Link>
      </div>
    );
  }

  return (
    <div className="grid gap-8 lg:grid-cols-[1fr_340px]">
      <div className="space-y-4">
        {items.map((item) => (
          <article key={item.productId} className="flex flex-col gap-4 rounded-2xl border border-rose-100 bg-white p-4 sm:flex-row sm:items-center">
            <img
              src={item.imageUrl}
              alt={item.name}
              className="h-28 w-28 shrink-0 rounded-xl bg-rose-50 object-contain"
            />
            <div className="min-w-0 flex-1">
              <h2 className="font-semibold text-stone-900">{item.name}</h2>
              <p className="mt-1 text-sm text-stone-500">{formatCurrency(item.unitPrice)}</p>
              <div className="mt-3 flex items-center gap-3">
                <div className="inline-flex items-center rounded-full border border-rose-200">
                  <button
                    type="button"
                    className="flex h-9 w-9 items-center justify-center rounded-full hover:bg-rose-50 disabled:opacity-40"
                    aria-label={`Giảm số lượng ${item.name}`}
                    disabled={item.quantity <= 1}
                    onClick={() => dispatch(updateQuantity({ productId: item.productId, quantity: item.quantity - 1 }))}
                  >
                    <Minus size={15} aria-hidden="true" />
                  </button>
                  <span className="min-w-8 text-center text-sm" aria-label="Số lượng">{item.quantity}</span>
                  <button
                    type="button"
                    className="flex h-9 w-9 items-center justify-center rounded-full hover:bg-rose-50 disabled:opacity-40"
                    aria-label={`Tăng số lượng ${item.name}`}
                    disabled={item.quantity >= item.stock}
                    onClick={() => dispatch(updateQuantity({ productId: item.productId, quantity: item.quantity + 1 }))}
                  >
                    <Plus size={15} aria-hidden="true" />
                  </button>
                </div>
                <button
                  type="button"
                  className="inline-flex items-center gap-1 rounded-full px-3 py-2 text-sm text-rose-700 hover:bg-rose-50"
                  onClick={() => dispatch(removeItem(item.productId))}
                  aria-label={`Xóa ${item.name} khỏi giỏ hàng`}
                >
                  <Trash2 size={16} aria-hidden="true" />
                  Xóa
                </button>
              </div>
            </div>
            <strong className="shrink-0 text-lg text-stone-900">
              {formatCurrency(item.unitPrice * item.quantity)}
            </strong>
          </article>
        ))}
      </div>

      <aside className="h-fit rounded-2xl border border-rose-100 bg-white p-5">
        <h2 className="text-lg font-semibold text-stone-900">Tóm tắt đơn hàng</h2>
        <div className="mt-5 flex justify-between gap-4 text-sm text-stone-600">
          <span>Tạm tính</span>
          <span>{formatCurrency(total)}</span>
        </div>
        <div className="mt-4 flex justify-between gap-4 border-t border-rose-100 pt-4 font-semibold text-stone-900">
          <span>Tổng cộng</span>
          <span>{formatCurrency(total)}</span>
        </div>
        <Link href="/thanh-toan" className="mt-5 flex min-h-11 items-center justify-center rounded-full bg-rose-700 px-5 py-2.5 text-sm font-semibold text-white hover:bg-rose-800">
          Tiến hành thanh toán
        </Link>
        <Button
          type="button"
          variant="secondary"
          className="mt-3 w-full"
          onClick={() => dispatch(clearCart())}
        >
          Xóa toàn bộ giỏ hàng
        </Button>
      </aside>
    </div>
  );
}
