"use client";

import { useEffect, useRef, useState, type ReactNode } from "react";
import { Provider, useDispatch, useSelector } from "react-redux";
import { makeStore, type AppDispatch, type AppStore, type RootState } from "@/store";
import { restoreCart, type CartLine } from "@/store/gioHangSlice";

const CART_STORAGE_KEY = "thanhtam-cart";

function isCartLine(value: unknown): value is CartLine {
  if (!value || typeof value !== "object") return false;
  const item = value as Record<string, unknown>;
  return Number.isInteger(item.productId)
    && typeof item.name === "string"
    && typeof item.imageUrl === "string"
    && typeof item.unitPrice === "number"
    && typeof item.quantity === "number"
    && typeof item.stock === "number";
}

function CartPersistence() {
  const dispatch = useDispatch<AppDispatch>();
  const items = useSelector((state: RootState) => state.gioHang.items);
  const [ready, setReady] = useState(false);

  useEffect(() => {
    try {
      const savedCart = window.localStorage.getItem(CART_STORAGE_KEY);
      if (savedCart) {
        const parsed: unknown = JSON.parse(savedCart);
        if (!Array.isArray(parsed) || !parsed.every(isCartLine)) {
          throw new Error("Dữ liệu giỏ hàng đã lưu không đúng định dạng");
        }
        dispatch(restoreCart(parsed));
      }
    } catch (error) {
      console.error("Không thể khôi phục giỏ hàng đã lưu:", error);
    } finally {
      setReady(true);
    }
  }, [dispatch]);

  useEffect(() => {
    if (!ready) return;
    try {
      window.localStorage.setItem(CART_STORAGE_KEY, JSON.stringify(items));
    } catch (error) {
      console.error("Không thể lưu giỏ hàng:", error);
    }
  }, [items, ready]);

  return null;
}

export function ReduxProvider({ children }: { children: ReactNode }) {
  const storeRef = useRef<AppStore | null>(null);
  if (!storeRef.current) storeRef.current = makeStore();

  return (
    <Provider store={storeRef.current}>
      <CartPersistence />
      {children}
    </Provider>
  );
}
