import { CheckoutForm } from "@/components/ThanhToan/CheckoutForm";

export default function CheckoutPage() {
  return (
    <section className="container section">
      <div className="mb-8 text-center">
        <p className="mb-2 text-xs font-bold tracking-[0.2em] text-rose-700">HOÀN TẤT ĐƠN HÀNG</p>
        <h1 className="section-title mb-3">Thông tin giao hàng</h1>
        <p className="mx-auto max-w-md text-sm leading-6 text-stone-600">Vui lòng điền thông tin nhận hàng để chúng tôi giao sản phẩm đến bạn.</p>
      </div>
      <CheckoutForm />
    </section>
  );
}
