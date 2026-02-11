const mongoose = require("mongoose");

const flowerSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  description: {
    type: String,
    required: true,
  },
  imageUrl: {
    type: String,
    required: true,
  },
  pdfUrl: {
    type: String,
    required: false,
    default: "",
  },
});

const Flower = mongoose.model("Flower", flowerSchema);
module.exports = Flower;
