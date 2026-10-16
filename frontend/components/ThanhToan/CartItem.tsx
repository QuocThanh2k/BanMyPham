type CartItemProps = { name: string; quantity: number; price: number };

export function CartItem({ name, quantity, price }: CartItemProps) {
  return <article className="card card-body" style={{ marginBlock: 12, display: "flex", justifyContent: "space-between", gap: 16 }}><span>{name} × {quantity}</span><strong>{new Intl.NumberFormat("vi-VN", { style: "currency", currency: "VND" }).format(price * quantity)}</strong></article>;
}
