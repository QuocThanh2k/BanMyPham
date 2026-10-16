"use client";

export function CheckoutForm() {
  return (
    <form className="form-panel" onSubmit={(event) => event.preventDefault()}>
      <label className="form-field" htmlFor="checkout-name">
        Họ và tên
        <input id="checkout-name" required name="name" autoComplete="name" placeholder="Tên người nhận hàng" />
      </label>
      <label className="form-field" htmlFor="checkout-phone">
        Số điện thoại
        <input id="checkout-phone" required name="phone" autoComplete="tel" inputMode="tel" placeholder="Số điện thoại liên hệ" />
      </label>
      <label className="form-field" htmlFor="checkout-address">
        Địa chỉ nhận hàng
        <textarea id="checkout-address" required name="address" autoComplete="street-address" placeholder="Số nhà, đường, phường/xã, quận/huyện, tỉnh/thành phố" />
      </label>
      <button className="button" type="submit">Đặt hàng</button>
    </form>
  );
}
