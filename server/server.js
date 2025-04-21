const express = require('express');
const app = express();
//const path = require('path');
const port = process.env.PORT || 8080; // Critical: Use Railway's PORT
// Serve static files from Flutter's build output
//app.use(express.static(path.join(__dirname, '../build/web')));

// Redirect all routes to index.html for Flutter's client-side routing
//app.get('/*', (req, res) => {
//  res.sendFile(path.join(__dirname, '../build/web', 'index.html'));
//});
//const port = process.env.PORT || 3000;
//app.listen(port, () => {
//  console.log(`Server running on port ${port}`);
//});

// Serve static files (Flutter's build/web folder)
app.use(express.static('build/web'));

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
