const express = require("express");
const controller = require("../controllers/donHangController");

const router = express.Router();
router.post("/", controller.create);

module.exports = router;
