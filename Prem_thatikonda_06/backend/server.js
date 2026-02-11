import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import bodyParser from "body-parser";

import connectDB from "./config/db.js";

import flowerRouter from "./routers/flowerRouter.js";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5001;

// Middleware
app.use(cors());
app.use(bodyParser.json({ limit: "50mb" }));
app.use("/uploads", express.static("uploads"));

// Routes
app.use("/api/flowers", flowerRouter);

// MongoDB Connection
connectDB();

// Start Server
app.listen(PORT, () => {
  console.log(`Server running on ${process.env.MONGO_URI}:PORT`);
});
