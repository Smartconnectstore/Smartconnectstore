#!/bin/bash
set -e

cd ~/nexacore

echo "🔹 Cleaning old lockfiles and node_modules..."
rm -rf node_modules package-lock.json .next
npm cache clean --force

echo "🔹 Installing compatible Next.js, React, React DOM..."
npm install next@15.4.2 react@18.2.0 react-dom@18.2.0

echo "🔹 Installing PostCSS and TailwindCSS..."
npm install tailwindcss@3.3.3 postcss@8.4.27 autoprefixer@10.4.15

echo "🔹 Creating Webpack-only next.config.cjs..."
cat > next.config.cjs << 'EOM'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true
};
module.exports = nextConfig
EOM

echo "🔹 Ensuring package.json scripts..."
if command -v jq >/dev/null 2>&1; then
    jq '.scripts.build="next build" | .scripts.dev="next dev" | .scripts.start="next start"' package.json > package.tmp.json
    mv package.tmp.json package.json
else
    # Fallback: manual edit
    sed -i '/"scripts": {/a \
    "build": "next build",\
    "dev": "next dev",\
    "start": "next start",' package.json
fi

echo "🔹 Installing dependencies..."
npm install

echo "🔹 Building project with Webpack..."
npm run build

if [ -n "$VERCEL_TOKEN" ]; then
    echo "🔹 Deploying to Vercel..."
    GIT_CONFIG_GLOBAL=/dev/null \
    GIT_CONFIG_SYSTEM=/dev/null \
    GIT_TERMINAL_PROMPT=0 \
    HOME=$PWD \
    vercel --prod --yes --token "$VERCEL_TOKEN"
fi

echo "✅ NexaCore build and deployment finished!"
