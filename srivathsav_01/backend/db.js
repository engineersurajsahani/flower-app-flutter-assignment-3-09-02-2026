const mongoose = require("mongoose");

mongoose.connect("mongodb://localhost:27017/flowerDB");

const db = mongoose.connection;

db.on("error", console.error.bind(console, "connection error:"));
db.on("open", function () {
  console.log("Connected to the database successfully");
});

module.exports = db;
module.exports = mongoose;
