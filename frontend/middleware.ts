import { withAuth } from "next-auth/middleware";

export default withAuth({
  pages: { signIn: "/dang-nhap" },
  callbacks: {
    authorized: ({ token, req }) => {
      if (req.nextUrl.pathname.startsWith("/quan-tri")) {
        return Boolean(token);
      }
      return Boolean(token);
    },
  },
});

export const config = { matcher: ["/ho-so/:path*", "/don-hang/:path*", "/quan-tri/:path*"] };
