// backend/testInsert.js

require("dotenv").config();
const mongoose = require("mongoose");

// Import the File model
const File = require("./models/File");

// Connect to MongoDB
mongoose.connect(process.env.MONGO_URI)
    .then(() => {
        console.log("✅ MongoDB connected successfully!");

        // Create a dummy file document
        const dummyFile = new File({
            filename: "dummy-image.jpg",
            filetype: "image",
            filepath: "uploads/images/dummy-image.jpg"
        });

        return dummyFile.save();
    })
    .then((doc) => {
        console.log("Document inserted:", doc);
        mongoose.connection.close();
    })
    .catch(err => console.log("❌ Error:", err));
