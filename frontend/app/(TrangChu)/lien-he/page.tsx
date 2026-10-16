"use client";

import { type FormEvent, useState } from "react";
import Link from "next/link";
import { ArrowUpRight, Clock3, MapPin, Phone } from "lucide-react";

const usefulArticles = [
  { href: "/blog#routine-cham-da", title: "Bắt đầu quy trình chăm sóc da đơn giản" },
  { href: "/blog#chong-nang-hang-ngay", title: "Đưa kem chống nắng vào thói quen mỗi ngày" },
  { href: "/blog#chon-my-pham", title: "Lưu ý khi lựa chọn mỹ phẩm" },
];

export default function ContactPage() {
  const [emailPrepared, setEmailPrepared] = useState(false);

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const formData = new FormData(event.currentTarget);
    const name = String(formData.get("name") || "").trim();
    const email = String(formData.get("email") || "").trim();
    const subject = String(formData.get("subject") || "").trim();
    const message = String(formData.get("message") || "").trim();
    const body = `Họ tên: ${name}\nEmail: ${email}\n\nNội dung:\n${message}`;

    setEmailPrepared(true);
    window.location.href = `mailto:diti202k2@gmail.com?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`;
  }

  return (
    <section className="container section">
      <div className="mb-9 max-w-2xl">
        <p className="mb-2 text-xs font-bold tracking-[0.2em] text-rose-700">THANH TÂM COSMETICS</p>
        <h1 className="section-title mb-3">Chúng tôi luôn sẵn sàng lắng nghe</h1>
        <p className="leading-7 text-stone-600">
          Cần tư vấn về sản phẩm hoặc đơn hàng? Gửi lời nhắn cho Thanh Tâm, đội ngũ của chúng tôi sẽ hỗ trợ bạn.
        </p>
      </div>

      <div className="grid items-start gap-8 lg:grid-cols-3">
        <form className="form-panel lg:col-span-2 lg:w-full lg:max-w-none" onSubmit={handleSubmit}>
          <div>
            <h2 className="text-xl font-semibold text-stone-900">Gửi lời nhắn</h2>
            <p className="mt-1 text-sm leading-6 text-stone-600">Điền thông tin bên dưới, ứng dụng email của bạn sẽ mở để gửi yêu cầu.</p>
          </div>

          <div className="grid gap-5 sm:grid-cols-2">
            <label className="form-field" htmlFor="contact-name">
              Tên của bạn
              <input id="contact-name" name="name" type="text" autoComplete="name" required maxLength={100} placeholder="Nguyễn Văn A" />
            </label>
            <label className="form-field" htmlFor="contact-email">
              Email của bạn
              <input id="contact-email" name="email" type="email" autoComplete="email" required maxLength={254} placeholder="ban@email.com" />
            </label>
          </div>

          <label className="form-field" htmlFor="contact-subject">
            Tiêu đề
            <input id="contact-subject" name="subject" type="text" required maxLength={150} placeholder="Bạn cần Thanh Tâm hỗ trợ điều gì?" />
          </label>

          <label className="form-field" htmlFor="contact-message">
            Nội dung tin nhắn
            <textarea id="contact-message" name="message" required maxLength={3000} rows={6} placeholder="Chia sẻ câu hỏi hoặc nội dung bạn cần hỗ trợ..." />
          </label>

          <div className="flex flex-col items-start gap-3 sm:flex-row sm:items-center sm:justify-between">
            <button className="button w-full sm:w-auto" type="submit">Mở email để gửi</button>
            <p aria-live="polite" className="text-xs leading-5 text-stone-500">
              {emailPrepared ? "Nếu ứng dụng email chưa mở, vui lòng gọi hotline để được hỗ trợ." : "Nút sẽ mở bản nháp gửi đến diti202k2@gmail.com để bạn kiểm tra và gửi."}
            </p>
          </div>
        </form>

        <aside className="grid gap-5">
          <a href="tel:0702932614" className="flex items-start gap-4 rounded-2xl border border-rose-100 bg-white p-5 shadow-sm transition hover:-translate-y-0.5 hover:border-rose-300 hover:shadow-md">
            <span className="flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-rose-50 text-rose-800">
              <Phone size={20} aria-hidden="true" />
            </span>
            <span>
              <span className="block font-semibold text-stone-900">Hotline tư vấn</span>
              <span className="mt-1 block text-sm text-stone-600">0702932614</span>
            </span>
          </a>

          <div className="flex items-start gap-4 rounded-2xl border border-rose-100 bg-white p-5 shadow-sm">
            <span className="flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-rose-50 text-rose-800">
              <MapPin size={20} aria-hidden="true" />
            </span>
            <span>
              <span className="block font-semibold text-stone-900">Hệ thống cửa hàng</span>
              <span className="mt-1 block text-sm leading-6 text-stone-600">Hơn 50 cửa hàng, phục vụ khách hàng trên toàn quốc.</span>
            </span>
          </div>

          <div className="rounded-2xl border border-rose-100 bg-rose-50/70 p-5">
            <div className="mb-4 flex items-center gap-2 text-sm font-semibold text-stone-900">
              <Clock3 size={17} className="text-rose-700" aria-hidden="true" />
              Cần tư vấn làm đẹp?
            </div>
            <p className="text-sm leading-6 text-stone-600">Tham khảo các bài viết chăm sóc da và lựa chọn mỹ phẩm từ Thanh Tâm.</p>
            <ul className="mt-4 grid gap-3">
              {usefulArticles.map((article) => (
                <li key={article.href}>
                  <Link href={article.href} className="group flex items-start justify-between gap-2 text-sm font-medium leading-5 text-rose-900 hover:text-rose-700">
                    {article.title}
                    <ArrowUpRight size={15} className="mt-0.5 shrink-0 transition-transform group-hover:-translate-y-0.5 group-hover:translate-x-0.5" aria-hidden="true" />
                  </Link>
                </li>
              ))}
            </ul>
          </div>
        </aside>
      </div>
    </section>
  );
}
