const express = require("express");
const flowerRouter = require("./routes/flowerRouter");
const db = require("./db");
const cors = require("cors");

const app = express();
const PORT = process.env.PORT || 4000;

app.use(cors());
app.use(express.json({ limit: "50mb" }));
app.use("/flowerDB", flowerRouter);

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
