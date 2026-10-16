"use client";

import { useEffect, useRef, useState } from "react";
import { getSession } from "next-auth/react";
import { ShoppingBag } from "lucide-react";
import { Button } from "@/components/SanPham/Button";
import type { SanPhamNoiBat } from "@/lib/products";
import { addItem } from "@/store/gioHangSlice";
import { useAppDispatch } from "@/store/hooks";

export function AddToCartButton({
  product,
  className,
}: {
  product: SanPhamNoiBat;
  className?: string;
}) {
  const dispatch = useAppDispatch();
  const [checkingSession, setCheckingSession] = useState(false);
  const pendingProductRef = useRef<number | null>(null);

  useEffect(() => {
    const url = new URL(window.location.href);
    if (url.searchParams.get("addToCart") !== String(product.MaSanPham)
      || pendingProductRef.current === product.MaSanPham) return;

    pendingProductRef.current = product.MaSanPham;
    void getSession()
      .then((session) => {
        if (!session) {
          pendingProductRef.current = null;
          return;
        }
        dispatch(addItem({
          productId: product.MaSanPham,
          name: product.TenSanPham,
          imageUrl: product.LinkAnh,
          unitPrice: product.Gia,
          quantity: 1,
          stock: product.SoLuongKho,
        }));
        url.searchParams.delete("addToCart");
        window.history.replaceState(window.history.state, "", `${url.pathname}${url.search}${url.hash}`);
      })
      .catch((error: unknown) => {
        pendingProductRef.current = null;
        console.error("Không thể hoàn tất việc thêm sản phẩm sau khi đăng nhập:", error);
        window.alert("Không thể thêm sản phẩm vào giỏ hàng. Vui lòng thử lại.");
      });
  }, [dispatch, product]);

  async function addProductToCart() {
    setCheckingSession(true);
    try {
      const session = await getSession();
      if (!session) {
        const returnUrl = `/san-pham/${encodeURIComponent(product.slug)}?addToCart=${product.MaSanPham}`;
        window.location.assign(`/dang-nhap?callbackUrl=${encodeURIComponent(returnUrl)}`);
        return;
      }

      dispatch(addItem({
        productId: product.MaSanPham,
        name: product.TenSanPham,
        imageUrl: product.LinkAnh,
        unitPrice: product.Gia,
        quantity: 1,
        stock: product.SoLuongKho,
      }));
    } catch (error) {
      console.error("Không thể xác minh phiên đăng nhập:", error);
      window.alert("Không thể xác minh trạng thái đăng nhập. Vui lòng thử lại.");
    } finally {
      setCheckingSession(false);
    }
  }

  return (
    <Button
      type="button"
      variant="secondary"
      className={className}
      disabled={checkingSession || product.SoLuongKho < 1}
      onClick={() => void addProductToCart()}
      aria-label={`Thêm ${product.TenSanPham} vào giỏ hàng`}
    >
      <ShoppingBag size={17} aria-hidden="true" />
      {checkingSession ? "Đang kiểm tra..." : product.SoLuongKho < 1 ? "Tạm hết hàng" : "Thêm vào giỏ"}
    </Button>
  );
}
