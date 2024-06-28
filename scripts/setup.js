#!/usr/bin/env node

const fs = require('fs');
const args = process.argv.slice(2);

// Object to store the parameters
const params = {};

// Process the command-line arguments
args.forEach((arg) => {
  const [key, value] = arg.split('=');
  if (key && value) {
    params[key.replace('--', '')] = value;
  }
});

const file = 'package.json';

// Parse package.json to object
const packageJson = JSON.parse(fs.readFileSync(file));

// Remove some default generated properties
if (packageJson.scripts) delete packageJson.scripts;
if (packageJson.keywords) delete packageJson.keywords;

// Setup scripts
const build = 'rm -rf build && NODE_ENV=production webpack';
const start = 'webpack serve';
const dev = 'webpack serve --mode development';

packageJson.scripts = {};
packageJson.scripts.build = build;
packageJson.scripts.start = start;
packageJson.scripts.dev = dev;

// Merge params passed as arguments to packageJson
const mergedParams = Object.assign({}, packageJson, params);

// Overwrite package.json
fs.writeFileSync(file, JSON.stringify(mergedParams, null, 2));
