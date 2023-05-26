#!/usr/bin/env node

const { exec } = require("child_process");
const path = require("path");

const versionsFile = path.join(process.cwd(), "versions.js");

const scriptPath = path.join(__dirname, "bin", "script.sh");

exec(`${scriptPath} ${versionsFile}`, (error, stdout, stderr) => {
  if (error) {
    console.error(`An error occurred: ${error.message}`);
    return;
  }
  if (stderr) {
    console.error(`Script encountered an error: ${stderr}`);
    return;
  }
  console.log(stdout);
});
