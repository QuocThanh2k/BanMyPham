require("dotenv").config();
const cors = require("cors");
const express = require("express");
const path = require("path");
const { connectDB } = require("./config/database");
const productRoutes = require("./routes/sanpham");
const orderRoutes = require("./routes/donhang");
const authRoutes = require("./routes/auth");
const adminRoutes = require("./routes/admin");
const { errorHandler, notFound } = require("./middlewares/errorHandler");

const app = express();
app.use(cors({ origin: process.env.CLIENT_ORIGIN || "http://localhost:3000" }));
app.use(express.json({ limit: "1mb" }));
app.use("/images", express.static(path.join(__dirname, "../images")));

app.get("/api/health", async (_req, res, next) => {
  try {
    const pool = await connectDB();
    await pool.request().query("SELECT 1");
    res.json({ status: "ok" });
  } catch (error) {
    next(error);
  }
});
app.use("/api/sanpham", productRoutes);
app.use("/api/donhang", orderRoutes);
app.use("/api/auth", authRoutes);
app.use("/api/admin", adminRoutes);
app.use(notFound);
app.use(errorHandler);

const port = Number(process.env.PORT || 4000);

async function startServer() {
  await connectDB();
  app.listen(port, () => console.log(`API server listening on port ${port}`));
}

startServer().catch((error) => {
  console.error("Unable to start API server:", error);
  process.exitCode = 1;
});
