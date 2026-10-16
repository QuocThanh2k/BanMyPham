import { notFound } from "next/navigation";

const policies: Record<string, { title: string; description: string }> = {
  "bao-mat": {
    title: "Chính sách bảo mật",
    description: "Thông tin cá nhân của khách hàng chỉ được sử dụng để xử lý đơn hàng và hỗ trợ dịch vụ. Hệ thống áp dụng kết nối HTTPS để bảo vệ dữ liệu trong quá trình truyền tải.",
  },
  "doi-tra": {
    title: "Đổi trả & hoàn tiền",
    description: "Vui lòng liên hệ bộ phận hỗ trợ khi sản phẩm bị lỗi hoặc không đúng với đơn đặt hàng. Sản phẩm cần được giữ nguyên bao bì để được hướng dẫn đổi trả.",
  },
  "van-chuyen": {
    title: "Chính sách giao hàng",
    description: "Đơn hàng được giao đến địa chỉ khách hàng cung cấp. Thời gian và phí giao hàng sẽ được xác nhận khi đặt hàng.",
  },
};

export default function PolicyPage({ params }: { params: { slug: string } }) {
  const { slug } = params;
  const policy = policies[slug];
  if (!policy) notFound();

  return (
    <section className="container min-h-[45vh] py-16">
      <h1 className="text-3xl font-semibold text-stone-900">{policy.title}</h1>
      <p className="mt-5 max-w-3xl leading-7 text-stone-600">{policy.description}</p>
      <p className="mt-4 text-sm text-stone-500">Liên hệ bộ phận chăm sóc khách hàng để được hỗ trợ thêm.</p>
    </section>
  );
}
