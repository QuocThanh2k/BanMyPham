const productModel = require("../models/sanPhamModel");

function withPublicImageUrl(product, req) {
  if (!product.imageUrl || /^https?:\/\//i.test(product.imageUrl)) return product;

  const normalizedPath = product.imageUrl.replace(/\\/g, "/");
  const imagesIndex = normalizedPath.toLowerCase().lastIndexOf("/images/");
  const relativePath = imagesIndex >= 0
    ? normalizedPath.slice(imagesIndex + 1)
    : normalizedPath.replace(/^\/+/, "");
  if (!relativePath.startsWith("images/")) return product;

  return {
    ...product,
    imageUrl: new URL(`/${relativePath}`, `${req.protocol}://${req.get("host")}`).href,
  };
}

async function list(req, res, next) {
  try {
    const limit = Math.min(Math.max(Number.parseInt(req.query.limit, 10) || 24, 1), 100);
    const offset = Math.max(Number.parseInt(req.query.offset, 10) || 0, 0);
    const categoryId = req.query.categoryId === undefined ? undefined : Number.parseInt(req.query.categoryId, 10);
    const categorySlug = typeof req.query.categorySlug === "string" ? req.query.categorySlug.trim() : undefined;
    const brandSlug = typeof req.query.brandSlug === "string" ? req.query.brandSlug.trim() : undefined;
    const search = typeof req.query.search === "string" ? req.query.search.trim() : undefined;
    if (categoryId !== undefined && (!Number.isInteger(categoryId) || categoryId < 1)) {
      return res.status(400).json({ error: "categoryId không hợp lệ" });
    }
    if (search !== undefined && search.length > 180) {
      return res.status(400).json({ error: "Từ khóa tìm kiếm không được vượt quá 180 ký tự" });
    }
    if ((categorySlug !== undefined && categorySlug.length > 180)
      || (brandSlug !== undefined && brandSlug.length > 180)) {
      return res.status(400).json({ error: "Bộ lọc danh mục hoặc thương hiệu không hợp lệ" });
    }
    const products = await productModel.findAll({
      categoryId,
      categorySlug: categorySlug || undefined,
      brandSlug: brandSlug || undefined,
      search: search || undefined,
      limit,
      offset,
    });
    res.json({ data: products.map((product) => withPublicImageUrl(product, req)), pagination: { limit, offset } });
  } catch (error) {
    next(error);
  }
}

async function getById(req, res, next) {
  try {
    const id = Number.parseInt(req.params.id, 10);
    if (!Number.isInteger(id) || id < 1) return res.status(400).json({ error: "Mã sản phẩm không hợp lệ" });
    const product = await productModel.findById(id);
    if (!product) return res.status(404).json({ error: "Không tìm thấy sản phẩm" });
    res.json({ data: withPublicImageUrl(product, req) });
  } catch (error) {
    next(error);
  }
}

async function getBySlug(req, res, next) {
  try {
    const product = await productModel.findBySlug(req.params.slug);
    if (!product) return res.status(404).json({ error: "Không tìm thấy sản phẩm" });
    res.json({ data: withPublicImageUrl(product, req) });
  } catch (error) {
    next(error);
  }
}

module.exports = { list, getById, getBySlug };
