const express = require('express');
const path = require('path');
const app = express();

// Serve static files from Flutter's build output
app.use(express.static(path.join(__dirname, '../build/web')));

// Redirect all routes to index.html for Flutter's client-side routing
app.get('/*', (req, res) => {
  res.sendFile(path.join(__dirname, '../build/web', 'index.html'));
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
