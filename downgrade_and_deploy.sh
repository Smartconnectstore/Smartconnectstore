#!/bin/bash
set -e

cd ~/nexacore

echo "🔹 Downgrading Next.js to 15.4.2 (Webpack only)..."
npm install next@15.4.2 react@18.2.0 react-dom@18.2.0

echo "🔹 Removing any Turbopack/experimental config..."
rm -f next.config.js next.config.mjs
cat > next.config.cjs << 'EOM'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true
};
module.exports = nextConfig
EOM

echo "🔹 Ensuring package.json scripts..."
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

if [ -z "$VERCEL_TOKEN" ]; then
    echo "⚠️  Please export VERCEL_TOKEN before deploying"
    exit 1
fi

echo "🔹 Deploying to Vercel..."
GIT_CONFIG_GLOBAL=/dev/null \
GIT_CONFIG_SYSTEM=/dev/null \
GIT_TERMINAL_PROMPT=0 \
HOME=$PWD \
vercel --prod --yes --token "$VERCEL_TOKEN"

echo "✅ Build and deployment complete!"
