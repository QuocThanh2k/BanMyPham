import type { Metadata } from "next";
import { Footer } from "@/components/GiaoDien/Footer";
import { Header } from "@/components/GiaoDien/Header";
import { ReduxProvider } from "@/components/ReduxProvider";
import "./globals.css";

export const metadata: Metadata = {
  title: "Thanh Tâm Cosmetics",
  description: "Mỹ phẩm chính hãng, chăm sóc vẻ đẹp mỗi ngày.",
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="vi">
      <body>
        <ReduxProvider>
          <Header />
          <main>{children}</main>
          <Footer />
        </ReduxProvider>
      </body>
    </html>
  );
}
