#!/bin/bash
set -e

echo "🧹 Cleaning old builds..."
rm -rf node_modules package-lock.json .next

echo "📦 Ensuring next.config.cjs uses Webpack (no Turbopack)..."
if [ -f next.config.js ]; then
    mv next.config.js next.config.cjs
fi

cat << 'EOC' > next.config.cjs
/** @type {import('next').NextConfig} */
const nextConfig = {
  webpack(config) {
    return config
  },
  experimental: {} // disable turbo or any other experimental
}

module.exports = nextConfig
EOC

echo "⚙️ Adding vercel-build script..."
jq '.scripts["vercel-build"]="next build"' package.json > package.tmp.json
mv package.tmp.json package.json

echo "📥 Installing dependencies..."
npm install --no-audit --no-fund

echo "🏗️ Building project locally..."
npm run vercel-build

if [ -z "$VERCEL_TOKEN" ]; then
  echo "⚠️ Please export VERCEL_TOKEN before deploying: export VERCEL_TOKEN=your_token_here"
  exit 1
fi

echo "🚀 Deploying to Vercel..."
vercel --prod --yes --token "$VERCEL_TOKEN"

echo "✅ Deployment complete!"
