const FREE_SHIPPING_THRESHOLD = 500000;
const STANDARD_SHIPPING_FEE = 30000;

function calculateShipping(subtotal) {
  if (!Number.isFinite(subtotal) || subtotal < 0) throw new RangeError("Subtotal phải là số không âm");
  return subtotal >= FREE_SHIPPING_THRESHOLD ? 0 : STANDARD_SHIPPING_FEE;
}

module.exports = { calculateShipping };
