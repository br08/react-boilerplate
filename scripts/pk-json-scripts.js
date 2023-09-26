#!/usr/bin/env node
const fs = require('fs');
const file = 'package.json';
const packageJson = JSON.parse(fs.readFileSync(file));
const build = 'rm -rf dist && NODE_ENV=production webpack';
const start = 'webpack serve';
const dev = 'webpack serve --mode development';
delete packageJson.scripts;
packageJson.scripts = {};
packageJson.scripts.build = build;
packageJson.scripts.start = start;
packageJson.scripts.dev = dev;
fs.writeFileSync(file, JSON.stringify(packageJson, null, 2));
