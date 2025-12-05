const express = require('express');

const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

// Serve UI static files if present (ui/dist)
const path = require('path');
const fs = require('fs');
const uiDist = path.join(__dirname, '..', 'ui', 'dist');
const apiPublic = path.join(__dirname, 'public');

if (fs.existsSync(uiDist)) {
  // copy ui/dist to api/public if not already present
  if (!fs.existsSync(apiPublic)) {
    fs.mkdirSync(apiPublic, { recursive: true });
  }
  // Only copy if newer or missing - a simple sync copy
  const copyRecursiveSync = (src, dest) => {
    const entries = fs.readdirSync(src, { withFileTypes: true });
    for (let entry of entries) {
      const srcPath = path.join(src, entry.name);
      const destPath = path.join(dest, entry.name);
      if (entry.isDirectory()) {
        if (!fs.existsSync(destPath)) fs.mkdirSync(destPath);
        copyRecursiveSync(srcPath, destPath);
      } else {
        const srcStat = fs.statSync(srcPath);
        if (!fs.existsSync(destPath) || fs.statSync(destPath).mtime < srcStat.mtime) {
          fs.copyFileSync(srcPath, destPath);
        }
      }
    }
  };
  try {
    copyRecursiveSync(uiDist, apiPublic);
    app.use(express.static(apiPublic));
    // Fallback to index.html for SPA
    app.get('*', (req, res) => {
      res.sendFile(path.join(apiPublic, 'index.html'));
    });
    console.log('Serving UI from', apiPublic);
  } catch (err) {
    console.error('Error copying UI files:', err);
  }
}

// Basic probes
app.get('/healthz', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

app.get('/', (req, res) => {
  res.send("Antivirus API — service opérationnel");
});

// Telemetry endpoint (example)
app.post('/api/v1/telemetry', (req, res) => {
  console.log('Télémétrie reçue :', req.body);
  res.status(200).send({ message: 'Télémétrie reçue avec succès' });
});

// Signatures/version endpoint (example)
app.get('/api/v1/signatures/latest', (req, res) => {
  res.status(200).send({
    version: '1.0.0',
    signatures: ['signature1', 'signature2', 'signature3'],
  });
});

// Scan report receiver
app.post('/api/v1/scan/report', (req, res) => {
  console.log('Rapport de scan reçu :', req.body);
  res.status(200).send({ message: 'Rapport reçu avec succès' });
});

// Update check (example manifest)
app.post('/api/v1/update/check', (req, res) => {
  res.status(200).send({
    manifest: {
      version: '1.0.1',
      url: 'https://example.com/update.zip',
    },
    signature: 'abc123signature',
  });
});

const server = app.listen(port, () => {
  console.log(`Antivirus API listening on port ${port}`);
});

// expose a lightweight probe for CI
module.exports.probe = async function () {
  return server.listening;
};