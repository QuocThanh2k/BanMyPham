import type { NextAuthOptions } from "next-auth";
import CredentialsProvider from "next-auth/providers/credentials";

export const authOptions: NextAuthOptions = {
  session: { strategy: "jwt" },
  providers: [
    CredentialsProvider({
      name: "Email và mật khẩu",
      credentials: {
        email: { label: "Email", type: "email" },
        password: { label: "Mật khẩu", type: "password" },
      },
      async authorize(credentials) {
        if (!credentials?.email || !credentials.password) return null;
        const apiUrl = process.env.BACKEND_API_URL || "http://localhost:4000/api";
        const response = await fetch(`${apiUrl}/auth/login`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ email: credentials.email, password: credentials.password }),
        });
        if (!response.ok) return null;
        const result = await response.json();
        return { ...result.user, backendToken: result.token };
      },
    }),
  ],
  secret: process.env.NEXTAUTH_SECRET,
  pages: { signIn: "/dang-nhap" },
  callbacks: {
    async jwt({ token, user }) {
      if (user) {
        token.sub = user.id;
        token.role = user.role;
        token.phone = user.phone;
        token.address = user.address;
        token.isActive = user.isActive;
        token.mustResetPassword = user.mustResetPassword;
        token.backendToken = user.backendToken;
        token.createdAt = user.createdAt instanceof Date
          ? user.createdAt.toISOString()
          : user.createdAt ?? null;
      }
      return token;
    },
    async session({ session, token }) {
      if (session.user) {
        session.user.id = token.sub || "";
        session.user.role = token.role;
        session.user.phone = token.phone ?? null;
        session.user.address = token.address ?? null;
        session.user.isActive = token.isActive ?? null;
        session.user.mustResetPassword = token.mustResetPassword ?? null;
        session.user.backendToken = token.backendToken ?? null;
        session.user.createdAt = token.createdAt instanceof Date
          ? token.createdAt.toISOString()
          : token.createdAt ?? null;
      }
      return session;
    },
  },
};
