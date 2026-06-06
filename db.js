const mongoose = require("mongoose");

const connectDB = async () => {
    const uri = process.env.MONGODB_URI;
    if (!uri) {
        console.warn('⚠️  MONGODB_URI not set; skipping MongoDB connection (safe for read-only or static requests).');
        return;
    }

    try {
        await mongoose.connect(uri, { serverSelectionTimeoutMS: 5000 });
        console.log("✅ MongoDB Connected");
    } catch (error) {
        console.error("❌ MongoDB Error:", error.message);
        // In serverless environments, do not exit the process; instead surface error and allow graceful degradation.
    }
};

module.exports = connectDB;