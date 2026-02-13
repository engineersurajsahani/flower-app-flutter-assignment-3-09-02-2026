const express = require("express");
const router = express.Router();
const multer = require("multer");
const { uploadFile, getFiles, deleteFile } = require("../controllers/fileController");

// Storage setup
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    if (file.mimetype.startsWith("image")) cb(null, "uploads/images");
    else if (file.mimetype === "application/pdf") cb(null, "uploads/pdfs");
    else cb(new Error("Unsupported file type"), null);
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + "-" + file.originalname);
  },
});

const upload = multer({ storage });

router.post("/upload", upload.single("file"), uploadFile);
router.get("/", getFiles);
router.delete("/:id", deleteFile);

module.exports = router;
