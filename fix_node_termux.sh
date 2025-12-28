#!/bin/bash
set -e

echo "🧹 Removing broken Node/NVM..."
unset PREFIX
rm -rf ~/.nvm
pkg uninstall -y nodejs nodejs-lts
rm -rf ~/node_modules
rm -f ~/.bashrc ~/.profile

echo "📦 Updating Termux packages..."
pkg update -y
pkg upgrade -y

echo "⚡ Installing Node.js LTS from Termux repo..."
pkg install -y nodejs-lts

echo "✅ Node.js installation complete!"
echo "Node version: $(node -v)"
echo "NPM version: $(npm -v)"
