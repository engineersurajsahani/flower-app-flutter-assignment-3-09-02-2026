const File = require("../models/File");
const fs = require("fs");
const path = require("path");

// Upload file
const uploadFile = async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ message: "No file uploaded" });

    const fileType = req.file.mimetype.startsWith("image") ? "image" : "pdf";

    const newFile = await File.create({
      filename: req.file.originalname,
      filetype: fileType,
      filepath: req.file.path, // stores relative path like uploads/images/xxx.jpg
    });

    res.status(201).json(newFile);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// Get all files
const getFiles = async (req, res) => {
  try {
    const files = await File.find();
    res.json(files);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// Delete file safely
const deleteFile = async (req, res) => {
  try {
    const file = await File.findById(req.params.id);

    if (!file) {
      return res.status(404).json({ message: "File not found" });
    }

    // Safe delete from disk
    const filePath = path.join(__dirname, "..", file.filepath);
    try {
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
      }
    } catch (err) {
      console.log("Warning: file deletion failed, continuing:", err.message);
    }

    // Delete from database
    await File.findByIdAndDelete(req.params.id);

    res.json({ message: "File deleted successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

module.exports = {
  uploadFile,
  getFiles,
  deleteFile,
};