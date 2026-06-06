const mongoose = require('mongoose');

const ProductSchema = new mongoose.Schema({
    title: String,
    description: String,
    category: String,
    image: String,
    price: Number,
    stock: Number,
    featured: Boolean,
    createdAt: {
        type: Date,
        default: Date.now
    }
});

// Export the model for use in the app
module.exports = mongoose.models.Product || mongoose.model('Product', ProductSchema);