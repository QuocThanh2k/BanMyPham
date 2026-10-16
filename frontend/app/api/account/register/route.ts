import { NextResponse } from "next/server";

export async function POST(request: Request) {
  const apiUrl = process.env.BACKEND_API_URL || "http://localhost:4000/api";
  const response = await fetch(`${apiUrl}/auth/register`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(await request.json()),
  });
  const result = await response.json();

  if (!response.ok) {
    return NextResponse.json(
      { error: result.error || "Không thể tạo tài khoản." },
      { status: response.status },
    );
  }

  return NextResponse.json({ user: result.user }, { status: response.status });
}
