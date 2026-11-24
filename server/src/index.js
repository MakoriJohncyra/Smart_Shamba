import "dotenv/config";
import express from "express";
import cors from "cors";
import { pool } from "./config/db.js";

const app = express();
const port = process.env.PORT || 5000;

app.use(cors({ origin: process.env.FRONTEND_URL || "http://localhost:5173" }));
app.use(express.json());

app.get("/api/health", async (_req, res) => {
  try {
    await pool.query("SELECT 1");
    res.json({ status: "ok", database: "connected" });
  } catch {
    res.status(503).json({ status: "error", database: "unavailable" });
  }
});

app.listen(port, () => {
  console.log(`Smart Shamba API listening on port ${port}`);
});
