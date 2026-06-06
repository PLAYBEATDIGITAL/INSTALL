require("dotenv").config();

const express = require("express");
const cors = require("cors");
const helmet = require("helmet");

const connectDB = require("./db");

process.on('uncaughtException', (err) => {
    console.error('Uncaught Exception:', err && (err.stack || err.message || err));
});

process.on('unhandledRejection', (reason) => {
    console.error('Unhandled Rejection:', reason);
});

const start = async () => {
    try {
        await connectDB();
    } catch (err) {
        console.error('Error during initial DB connect:', err && (err.message || err));
    }

    const app = express();

    app.use(cors());
    app.use(helmet());
    app.use(express.json());

    app.get("/", (req, res) => {
        res.json({ status: "PlayBeat Backend Online" });
    });

    const PORT = process.env.PORT || 5000;

    app.listen(PORT, () => {
        console.log(`🚀 Server running on port ${PORT}`);
    });
};

start();