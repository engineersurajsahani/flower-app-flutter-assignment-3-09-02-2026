import Flower from "../models/Flower.js";

export async function getFlowers(req, res) {
  try {
    const flowers = await Flower.find();
    if (!flowers) {
      return res.status(404).json({ message: "No flowers found" });
    }
    return res.status(200).json({ message: "success", data: flowers });
  } catch (error) {
    console.error("Error fetching flowers:", error);
    return res.status(500).json({ message: "Internal server error" });
  }
}

export async function getFlowerById(req, res) {
  try {
    const flower = await Flower.findById(req.params.id);
    if (!flower) {
      return res.status(404).json({ message: "Flower not found" });
    }
    return res.status(200).json({ message: "success", data: flower });
  } catch (error) {
    console.error("Error fetching flower:", error);
    return res.status(500).json({ message: "Internal server error" });
  }
}

import fs from "fs";
import path from "path";

// Helper to save base64 file
const saveBase64 = (base64Data) => {
  if (!base64Data || !base64Data.includes("base64,")) return "";
  const matches = base64Data.match(/^data:([A-Za-z-+\/]+);base64,(.+)$/);
  if (matches.length !== 3) return "";

  const type = matches[1];
  const buffer = Buffer.from(matches[2], "base64");
  const extension = type.split("/")[1];
  const filename = `${Date.now()}-${Math.random().toString(36).substr(2, 9)}.${extension}`;

  const uploadDir = "uploads";
  if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir);
  }

  fs.writeFileSync(path.join(uploadDir, filename), buffer);
  return `/uploads/${filename}`; // Return relative URL
};

export async function postFlower(req, res) {
  try {
    const { name, description, imageUrl, pdfUrl } = req.body;

    // Save image if provided as base64
    let finalImageUrl = imageUrl;
    if (imageUrl && imageUrl.startsWith("data:image")) {
      finalImageUrl = saveBase64(imageUrl);
    }

    // Save pdf if provided as base64
    let finalPdfUrl = pdfUrl;
    if (pdfUrl && pdfUrl.startsWith("data:application/pdf")) {
      finalPdfUrl = saveBase64(pdfUrl);
    }

    const flower = new Flower({
      name,
      description,
      imageUrl: finalImageUrl || "",
      pdfUrl: finalPdfUrl || "",
    });

    if (!flower) {
      return res.status(400).json({ message: "Flower couldn't be created" });
    }
    await flower.save();
    return res.status(201).json({ message: "success", data: flower });
  } catch (error) {
    console.error("Error posting flower:", error);
    return res.status(500).json({ message: "Internal server error" });
  }
}

export async function editFlower(req, res) {
  try {
    const { name, description, imageUrl, pdfUrl } = req.body;

    // Save image if provided as base64 (only if changed)
    let finalImageUrl = imageUrl;
    if (imageUrl && imageUrl.startsWith("data:image")) {
      finalImageUrl = saveBase64(imageUrl);
    }

    // Save pdf if provided as base64 (only if changed)
    let finalPdfUrl = pdfUrl;
    if (pdfUrl && pdfUrl.startsWith("data:application/pdf")) {
      finalPdfUrl = saveBase64(pdfUrl);
    }

    const flower = await Flower.findByIdAndUpdate(
      req.params.id,
      {
        name,
        description,
        imageUrl: finalImageUrl,
        pdfUrl: finalPdfUrl,
      },
      { new: true }, // Return the updated document
    );
    if (!flower) {
      return res.status(404).json({ message: "Flower not found" });
    }
    return res.status(200).json({ message: "success", data: flower });
  } catch (error) {
    console.error("Error editing flower:", error);
    return res.status(500).json({ message: "Internal server error" });
  }
}

export async function deleteFlower(req, res) {
  try {
    const flower = await Flower.findByIdAndDelete(req.params.id);
    if (!flower) {
      return res.status(404).json({ message: "Flower not found" });
    }
    return res.status(200).json({ message: "success", data: flower });
  } catch (error) {
    console.error("Error deleting flower:", error);
    return res.status(500).json({ message: "Internal server error" });
  }
}
