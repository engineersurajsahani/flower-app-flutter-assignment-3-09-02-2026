// backend/server.js

const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const dotenv = require("dotenv");

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());
app.use("/uploads", express.static("uploads"));

// Connect to MongoDB (Mongoose 7+ doesn't need useNewUrlParser/useUnifiedTopology)
mongoose.connect(process.env.MONGO_URI)
    .then(() => console.log("✅ MongoDB connected successfully!"))
    .catch(err => console.log("❌ MongoDB connection error:", err));

// Routes
const fileRoutes = require("./routes/fileRoutes");
app.use("/api/files", fileRoutes);

// Start server
const PORT = process.env.PORT || 3001;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
