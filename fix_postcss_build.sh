#!/bin/bash
set -e

cd ~/nexacore

echo "🔹 Cleaning node_modules and lockfile..."
rm -rf node_modules package-lock.json
npm cache clean --force

echo "🔹 Installing compatible dependencies..."
npm install next@15.4.2 react@18.2.0 react-dom@18.2.0
npm install tailwindcss@3.3.3 postcss@8.4.27 autoprefixer@10.4.15

echo "🔹 Ensuring package.json scripts..."
if ! jq -e '.scripts' package.json >/dev/null; then
    jq '.scripts = { "build":"next build", "dev":"next dev", "start":"next start" }' package.json > package.tmp.json
else
    jq '.scripts.build="next build" | .scripts.dev="next dev" | .scripts.start="next start"' package.json > package.tmp.json
fi
mv package.tmp.json package.json

echo "🔹 Creating next.config.cjs for Webpack..."
cat > next.config.cjs << 'EOM'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true
};
module.exports = nextConfig
EOM

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

echo "✅ PostCSS build fix, build, and deployment complete!"
