require("dotenv").config();
const express = require("express");
const app = express();
const port = process.env.PORT || 3000;

app.get("/", (req, res) => res.send("Private Service"));

app.get("/hello", (req, res) =>
  res.json({
    data: "Hello World!",
  })
);

app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});

// add SIGINT handler
process.on("SIGINT", () => {
  console.info("SIGINT signal received.");
  process.exit(0);
});
