function notFound(req, res) {
  res.status(404).json({ error: `Không tìm thấy API ${req.method} ${req.originalUrl}` });
}

function errorHandler(error, _req, res, _next) {
  console.error(error);
  const status = Number.isInteger(error.status) ? error.status : 500;
  res.status(status).json({ error: status === 500 ? "Đã xảy ra lỗi máy chủ" : error.message });
}

module.exports = { notFound, errorHandler };
