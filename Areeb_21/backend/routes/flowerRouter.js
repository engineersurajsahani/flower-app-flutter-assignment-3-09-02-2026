const express = require('express');
const Flower = require('../models/Flower');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const router = express.Router();

// Create uploads directory if it doesn't exist
const uploadsDir = path.join(__dirname, '../uploads');
if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir, { recursive: true });
}

// Configure multer for file uploads
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, uploadsDir);
    },
    filename: function (req, file, cb) {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
    }
});

const upload = multer({ storage: storage });

router.get('/', async (req, res) => {
    const flowers = await Flower.find();
    res.status(200).json(flowers);
});

router.get('/:id', async (req, res) => {
    try {
        const flower = await Flower.findById(req.params.id);
        if (!flower) {
            return res.status(404).json({ message: 'Flower not found' });
        }
        res.status(200).json(flower);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

router.post('/', upload.fields([{ name: 'image', maxCount: 1 }, { name: 'pdf', maxCount: 1 }]), async (req, res) => {
    try {
        const { name, description } = req.body;
        
        let imageUrl = req.body.imageUrl;
        let pdfUrl = req.body.pdfUrl;

        // If files are uploaded, use the uploaded file URLs
        if (req.files) {
            if (req.files.image) {
                imageUrl = `http://localhost:4000/uploads/${req.files.image[0].filename}`;
            }
            if (req.files.pdf) {
                pdfUrl = `http://localhost:4000/uploads/${req.files.pdf[0].filename}`;
            }
        }

        const newFlower = {
            name,
            description,
            imageUrl,
            pdfUrl
        };

        const flower = new Flower(newFlower);
        await flower.save();
        res.status(201).json({ message: 'Flower added successfully', flower });

    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

router.put('/:id', async (req, res) => {
    try {
        ;
        const flower = await Flower.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!flower) {
            return res.status(404).json({ message: 'Flower not found' });
        }
        res.status(200).json({ message: 'Flower updated successfully' });

    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

router.delete('/:id', async (req, res) => {
    try {
        const flower = await Flower.findByIdAndDelete(req.params.id);
        if (!flower) {
            return res.status(404).json({ message: 'Flower not found' });
        }
        res.status(200).json({ message: 'Flower deleted successfully' });

    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

module.exports = router;