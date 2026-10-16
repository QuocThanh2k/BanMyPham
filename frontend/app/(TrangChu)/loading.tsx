export default function HomeLoading() {
  return (
    <div className="container py-20" role="status" aria-label="Đang tải sản phẩm">
      <div className="h-8 w-56 animate-pulse rounded bg-rose-100" />
      <div className="mt-8 grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4">
        {Array.from({ length: 4 }, (_, index) => <div key={index} className="aspect-[4/5] animate-pulse rounded-2xl bg-rose-50" />)}
      </div>
    </div>
  );
}
