import { getPublicImageUrl } from "@/lib/products";

const articles = [
  {
    id: "routine-cham-da",
    category: "CHĂM SÓC DA",
    title: "Bắt đầu quy trình chăm sóc da đơn giản",
    image: "images/blog/blog-content1.jpg",
    imageAlt: "Hướng dẫn chăm sóc da và làm sạch lỗ chân lông",
    paragraphs: [
      "Một quy trình cơ bản có thể bắt đầu với các bước làm sạch, dưỡng ẩm và chống nắng vào ban ngày. Hãy chọn sản phẩm phù hợp với tình trạng da của bạn.",
      "Khi thêm sản phẩm mới, nên thử từng món một và theo dõi phản ứng của da. Nếu có kích ứng kéo dài, hãy ngừng sử dụng và hỏi ý kiến chuyên gia.",
    ],
  },
  {
    id: "chong-nang-hang-ngay",
    category: "BẢO VỆ DA",
    title: "Đưa kem chống nắng vào thói quen mỗi ngày",
    image: "images/blog/blog-content2.jpg",
    imageAlt: "Sản phẩm mỹ phẩm dùng trong quy trình chăm sóc da",
    paragraphs: [
      "Kem chống nắng giúp bảo vệ da trước tia UV. Chọn sản phẩm phù hợp với nhu cầu sử dụng, thoa đủ lượng theo hướng dẫn trên bao bì và bôi lại khi cần.",
      "Kết hợp thêm các biện pháp che chắn như mũ, kính và áo chống nắng khi hoạt động ngoài trời.",
    ],
  },
  {
    id: "chon-my-pham",
    category: "MẸO LÀM ĐẸP",
    title: "Lưu ý khi lựa chọn mỹ phẩm",
    image: "images/blog/blog-content3.jpg",
    imageAlt: "Bảng màu trang điểm với các sắc hồng tự nhiên",
    paragraphs: [
      "Đọc kỹ thành phần, hướng dẫn sử dụng và hạn dùng trước khi chọn sản phẩm. Ưu tiên mua hàng có nguồn gốc rõ ràng.",
      "Nhu cầu chăm sóc da mỗi người khác nhau; lựa chọn sản phẩm nên dựa vào loại da và mục tiêu chăm sóc của bạn.",
    ],
  },
];

export default function BlogPage() {
  return (
    <section className="container py-12 sm:py-16">
      <p className="text-xs font-bold tracking-[0.2em] text-rose-700">KIẾN THỨC LÀM ĐẸP</p>
      <h1 className="mt-2 text-3xl font-semibold text-stone-900 sm:text-4xl">Blog chăm sóc sắc đẹp</h1>
      <div className="mt-8 grid gap-6 lg:grid-cols-3">
        {articles.map((article) => (
          <a
            key={article.id}
            href={`#${article.id}`}
            className="group overflow-hidden rounded-2xl border border-rose-100 bg-white transition hover:-translate-y-1 hover:shadow-lg"
          >
            <img
              src={getPublicImageUrl(article.image)}
              alt={article.imageAlt}
              className="aspect-[16/10] w-full object-cover transition duration-500 group-hover:scale-[1.03]"
            />
            <div className="p-5">
              <p className="text-xs font-bold tracking-wider text-rose-700">{article.category}</p>
              <h2 className="mt-3 text-xl font-semibold text-stone-900">{article.title}</h2>
              <span className="mt-4 inline-block text-sm font-semibold text-rose-800 group-hover:underline">
                Đọc bài viết
              </span>
            </div>
          </a>
        ))}
      </div>
      <div className="mt-10 space-y-6">
        {articles.map((article) => (
          <article id={article.id} key={article.id} className="scroll-mt-28 rounded-2xl bg-rose-50/70 p-6 sm:p-8">
            <div className="grid items-center gap-6 md:grid-cols-[minmax(0,0.8fr)_minmax(0,1.2fr)]">
              <img
                src={getPublicImageUrl(article.image)}
                alt={article.imageAlt}
                loading="lazy"
                className="aspect-[4/3] w-full rounded-xl bg-white object-cover"
              />
              <div>
                <p className="text-xs font-bold tracking-wider text-rose-700">{article.category}</p>
                <h2 className="mt-2 text-2xl font-semibold text-stone-900">{article.title}</h2>
                {article.paragraphs.map((paragraph) => (
                  <p key={paragraph} className="mt-4 leading-7 text-stone-600">{paragraph}</p>
                ))}
              </div>
            </div>
          </article>
        ))}
      </div>
    </section>
  );
}
