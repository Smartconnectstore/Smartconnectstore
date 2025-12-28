#!/bin/bash
set -e

# Navigate to project directory
cd ~/nexacore

echo "🔹 Creating/fixing next.config.js for Webpack..."
# If package.json is ESM, use next.config.mjs
if grep -q '"type": "module"' package.json; then
    cat > next.config.mjs << 'EOM'
export default {
  experimental: {
    turbo: false
  }
}
EOM
else
    cat > next.config.js << 'EOM'
/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    turbo: false
  }
}
module.exports = nextConfig
EOM
fi

echo "🔹 Ensuring package.json scripts..."
# Check if scripts exist
if ! jq -e '.scripts' package.json >/dev/null; then
    jq '.scripts = { "build":"next build", "dev":"next dev", "start":"next start" }' package.json > package.tmp.json
else
    jq '.scripts.build="next build" | .scripts.dev="next dev" | .scripts.start="next start"' package.json > package.tmp.json
fi
mv package.tmp.json package.json

echo "🔹 Installing dependencies..."
npm install

echo "🔹 Building project..."
npm run build

# Deploy to Vercel
if [ -z "$VERCEL_TOKEN" ]; then
    echo "⚠️ Please export VERCEL_TOKEN before deploying: export VERCEL_TOKEN=your_token"
    exit 1
fi

echo "🔹 Deploying to Vercel..."
GIT_CONFIG_GLOBAL=/dev/null \
GIT_CONFIG_SYSTEM=/dev/null \
GIT_TERMINAL_PROMPT=0 \
HOME=$PWD \
vercel --prod --yes --token "$VERCEL_TOKEN"

echo "✅ Update, build, and deployment complete!"
