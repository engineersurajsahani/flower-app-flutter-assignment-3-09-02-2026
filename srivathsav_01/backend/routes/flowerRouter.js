const express = require("express");
const router = express.Router();
const Flower = require("../model/flower");

router.get("/flowers", async (req, res) => {
  try {
    const flowers = await Flower.find();
    res.json(flowers);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.get("/flowers/:id", getFlower, async (req, res) => {
  try {
    const flower = await Flower.findById(req.params.id);
    if (!flower) {
      return res.status(404).json({ message: "Flower not found" });
    }
    res.status(200).json(flower);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.post("/flowers", async (req, res) => {
  const flower = new Flower({
    name: req.body.name,
    description: req.body.description,
    imageUrl: req.body.imageUrl,
    pdfUrl: req.body.pdfUrl,
  });

  try {
    const newFlower = await flower.save();
    res.status(201).json(newFlower);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

router.delete("/flowers/:id", getFlower, async (req, res) => {
  try {
    await res.flower.deleteOne();
    res.json({ message: "Deleted Flower" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.put("/flowers/:id", getFlower, async (req, res) => {
  if (req.body.name != null) {
    res.flower.name = req.body.name;
  }
  if (req.body.description != null) {
    res.flower.description = req.body.description;
  }
  if (req.body.imageUrl != null) {
    res.flower.imageUrl = req.body.imageUrl;
  }
  if (req.body.pdfUrl != null) {
    res.flower.pdfUrl = req.body.pdfUrl;
  }

  try {
    const updatedFlower = await res.flower.save();
    res.json(updatedFlower);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

async function getFlower(req, res, next) {
  let flower;
  try {
    flower = await Flower.findById(req.params.id);
    if (flower == null) {
      return res.status(404).json({ message: "Cannot find flower" });
    }
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }

  res.flower = flower;
  next();
}

module.exports = router;
