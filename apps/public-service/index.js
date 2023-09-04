require("dotenv").config();
const express = require("express");
const axios = require("axios");
const app = express();
const port = process.env.PORT || 3000;
const private_url = process.env.PRIVATE_URL ?? "http://localhost:3000";

app.get("/", (req, res) => res.send("Public Service"));

app.get("/private", (req, res) => {
  const { GoogleAuth } = require("google-auth-library");
  const { URL } = require("url");
  const auth = new GoogleAuth();
  const targetAudience = new URL(private_url).origin;

  async function request() {
    console.info(
      `request ${private_url} with target audience ${targetAudience}`
    );
    const client = await auth.getIdTokenClient(targetAudience);
    console.log("client", client);
    const response = await client.request({
      url: "/hello",
      baseURL: private_url,
    });
    res.json(response.data);
  }

  request().catch((err) => {
    console.error("request catch:", err.message);
    res.status(401).send(err.message);
  });
});

app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});

// add SIGINT handler
process.on("SIGINT", () => {
  console.info("SIGINT signal received.");
  process.exit(0);
});
