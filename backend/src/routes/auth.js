const express = require("express");
const controller = require("../controllers/authController");
const { requireAuth } = require("../middlewares/auth");

const router = express.Router();
router.post("/login", controller.login);
router.post("/register", controller.register);
router.get("/me", requireAuth, controller.currentUser);

module.exports = router;
