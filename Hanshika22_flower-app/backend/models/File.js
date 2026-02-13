const mongoose = require("mongoose");

const fileSchema = new mongoose.Schema({
    filename: String,
    filetype: String, // "image" or "pdf"
    filepath: String,
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model("File", fileSchema);
