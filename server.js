const express = require('express');
const { spawn } = require('child_process');
const path = require('path');
const cors = require('cors');

const app = express();
const PORT = 3073;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('dist'));

// Serve React app
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'dist', 'index.html'));
});

// Deploy endpoint
app.post('/deploy', (req, res) => {
  console.log('Deploy request received');
  
  // Set headers for Server-Sent Events
  res.writeHead(200, {
    'Content-Type': 'text/plain',
    'Cache-Control': 'no-cache',
    'Connection': 'keep-alive',
    'Access-Control-Allow-Origin': '*',
  });

  // Execute the deploy script
  const deployScript = spawn('bash', ['./deploy.sh'], {
    cwd: __dirname
  });

  // Send output line by line
  deployScript.stdout.on('data', (data) => {
    const output = data.toString();
    console.log('STDOUT:', output);
    res.write(output);
  });

  deployScript.stderr.on('data', (data) => {
    const output = data.toString();
    console.log('STDERR:', output);
    res.write(`ERROR: ${output}`);
  });

  deployScript.on('close', (code) => {
    console.log(`Deploy script exited with code ${code}`);
    res.write(`\n--- Deploy completed with exit code: ${code} ---\n`);
    res.end();
  });

  deployScript.on('error', (error) => {
    console.error('Error executing deploy script:', error);
    res.write(`\nERROR: Failed to execute deploy script: ${error.message}\n`);
    res.end();
  });
});

app.listen(PORT, () => {
  console.log(`GitLab Deployment Server running on http://localhost:${PORT}`);
});
