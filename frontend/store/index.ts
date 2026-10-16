import { configureStore } from "@reduxjs/toolkit";
import gioHangReducer from "./gioHangSlice";

export const makeStore = () =>
  configureStore({
    reducer: {
      gioHang: gioHangReducer,
    },
  });

export type AppStore = ReturnType<typeof makeStore>;
export type RootState = ReturnType<AppStore["getState"]>;
export type AppDispatch = AppStore["dispatch"];
