import "next-auth";
import "next-auth/jwt";

declare module "next-auth" {
  interface User {
    id: string;
    role?: "customer" | "admin" | "super_admin";
    backendToken?: string | null;
    phone?: string | null;
    address?: string | null;
    isActive?: boolean | null;
    mustResetPassword?: boolean | null;
    createdAt?: string | Date | null;
  }

  interface Session {
    user: User & {
      role?: "customer" | "admin" | "super_admin";
      backendToken: string | null;
      phone: string | null;
      address: string | null;
      isActive: boolean | null;
      mustResetPassword: boolean | null;
      createdAt: string | null;
    };
  }
}

declare module "next-auth/jwt" {
  interface JWT {
    role?: "customer" | "admin" | "super_admin";
    backendToken?: string | null;
    phone?: string | null;
    address?: string | null;
    isActive?: boolean | null;
    mustResetPassword?: boolean | null;
    createdAt?: string | Date | null;
  }
}
