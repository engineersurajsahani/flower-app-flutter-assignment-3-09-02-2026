import express from "express";
import {
  getFlowers,
  getFlowerById,
  postFlower,
  editFlower,
  deleteFlower,
} from "../controllers/flowerController.js";

const router = express.Router();

router.get("/", getFlowers);
router.get("/:id", getFlowerById);
router.post("/", postFlower);
router.put("/:id", editFlower);
router.delete("/:id", deleteFlower);

export default router;
