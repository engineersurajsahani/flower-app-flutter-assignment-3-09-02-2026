const express = require('express');
const flowerRouter = require('./routes/flowerRouter');
const db = require('./db');
const cors = require('cors');
const path = require('path');

const app = express();
app.use(cors());
app.use(express.json());

// Serve static files from the uploads directory
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

app.use('/flowers', flowerRouter);

app.listen(4000, () => {
    console.log('Server is running on port 4000');
});