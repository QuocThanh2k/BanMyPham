const express = require("express");
const controller = require("../controllers/sanPhamController");

const router = express.Router();
router.get("/", controller.list);
router.get("/slug/:slug", controller.getBySlug);
router.get("/:id", controller.getById);

module.exports = router;
