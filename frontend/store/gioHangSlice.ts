import { createSlice, type PayloadAction } from "@reduxjs/toolkit";

export type CartLine = {
  productId: number;
  name: string;
  imageUrl: string;
  unitPrice: number;
  quantity: number;
  stock: number;
};

type CartState = {
  items: CartLine[];
};

const initialState: CartState = { items: [] };

const gioHangSlice = createSlice({
  name: "gioHang",
  initialState,
  reducers: {
    addItem(state, action: PayloadAction<CartLine>) {
      const existing = state.items.find((line) => line.productId === action.payload.productId);
      if (existing) {
        existing.name = action.payload.name;
        existing.imageUrl = action.payload.imageUrl;
        existing.unitPrice = action.payload.unitPrice;
        existing.stock = action.payload.stock;
        existing.quantity = Math.min(existing.quantity + action.payload.quantity, existing.stock);
      } else {
        state.items.push({
          ...action.payload,
          quantity: Math.min(action.payload.quantity, action.payload.stock),
        });
      }
    },
    updateQuantity(state, action: PayloadAction<{ productId: number; quantity: number }>) {
      const item = state.items.find((line) => line.productId === action.payload.productId);
      if (item) item.quantity = Math.max(1, Math.min(action.payload.quantity, item.stock));
    },
    removeItem(state, action: PayloadAction<number>) {
      state.items = state.items.filter((item) => item.productId !== action.payload);
    },
    restoreCart(state, action: PayloadAction<CartLine[]>) {
      state.items = action.payload;
    },
    clearCart(state) {
      state.items = [];
    },
  },
});

export const { addItem, updateQuantity, removeItem, restoreCart, clearCart } = gioHangSlice.actions;
export default gioHangSlice.reducer;
