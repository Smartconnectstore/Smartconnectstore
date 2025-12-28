#!/bin/bash
set -e

# Go to project directory
cd ~/nexacore

echo "🔹 Removing experimental Turbopack config and forcing Webpack..."

# Rename next.config.js to next.config.cjs if it exists
if [ -f "next.config.js" ]; then
    mv next.config.js next.config.cjs
fi

# Overwrite next.config.cjs with Webpack-only config
cat << 'EOC' > next.config.cjs
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  experimental: {},  // remove turbo key
  webpack(config) {
    return config;  // use default Webpack
  },
};

module.exports = nextConfig;
EOC

echo "🔹 Ensuring package.json scripts exist..."
if ! grep -q '"build"' package.json; then
  jq '.scripts.build="next build" | .scripts.dev="next dev" | .scripts.start="next start" | .type="module"' package.json > package.tmp.json
  mv package.tmp.json package.json
fi

echo "🔹 Installing dependencies..."
npm install

echo "🔹 Building project with Webpack..."
npm run build

# Deploy to Vercel
if [ -z "$VERCEL_TOKEN" ]; then
  echo "⚠️ Please export VERCEL_TOKEN first: export VERCEL_TOKEN=your_token_here"
  exit 1
fi

echo "🔹 Deploying to Vercel..."
GIT_CONFIG_GLOBAL=/dev/null \
GIT_CONFIG_SYSTEM=/dev/null \
GIT_TERMINAL_PROMPT=0 \
HOME=$PWD \
vercel --prod --yes --token "$VERCEL_TOKEN"

echo "✅ Build and deployment complete!"
