const express = require("express");
const controller = require("../controllers/adminController");
const { requireAuth, requireAdmin, requireSuperAdmin } = require("../middlewares/auth");

const router = express.Router();
router.use(requireAuth, requireAdmin);
router.get("/overview", controller.overview);
router.get("/products", controller.listProducts);
router.get("/catalog-options", controller.catalogOptions);
router.post("/products", controller.createProduct);
router.put("/products/:id", controller.updateProduct);
router.delete("/products/:id", controller.archiveProduct);
router.patch("/products/:id/restore", controller.restoreProduct);
router.get("/users", controller.listUsers);
router.patch("/users/:id", controller.updateUser);
router.get("/orders", controller.listOrders);
router.patch("/orders/:id/status", controller.updateOrderStatus);
router.get("/access", requireSuperAdmin, (_req, res) => res.json({ data: { canManageRoles: true } }));

module.exports = router;
