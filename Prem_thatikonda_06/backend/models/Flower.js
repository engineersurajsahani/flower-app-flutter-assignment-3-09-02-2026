import mongoose, { Schema } from "mongoose";

const flowerSchema = new Schema({
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
  },
  pdfUrl: {
    type: String,
  },
});

export default mongoose.model("Flower", flowerSchema);
