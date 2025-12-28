#!/bin/bash
set -e

# --- Configuration ---
NEXT_VERSION="13.4.16"   # stable Webpack-friendly version
REACT_VERSION="18.2.0"
REACT_DOM_VERSION="18.2.0"

# --- Clean old builds ---
echo "🧹 Cleaning old build artifacts..."
rm -rf node_modules package-lock.json .next

# --- Install stable Next.js and React ---
echo "📦 Installing stable Next.js and React versions..."
npm install next@$NEXT_VERSION react@$REACT_VERSION react-dom@$REACT_DOM_VERSION --no-audit --no-fund

# --- Fix next.config.js to disable Turbopack ---
echo "⚙️ Patching next.config.js for Webpack-only build..."
cat << 'CONFIG' > next.config.js
/** @type {import('next').NextConfig} */
const nextConfig = {
  webpack: (config) => config,
  experimental: {
    turbo: false, // disable Turbopack
  },
};
module.exports = nextConfig;
CONFIG

# --- Fix fonts in layout.tsx ---
LAYOUT_FILE="app/layout.tsx"
if [ -f "$LAYOUT_FILE" ]; then
  echo "🎨 Replacing unknown fonts in layout.tsx..."
  sed -i "s|import { Geist.*} from .*|import { Inter } from 'next/font/google';\nconst inter = Inter({ subsets: ['latin'], display: 'swap' });|" "$LAYOUT_FILE"
  sed -i "s|className=.*|className={inter.className}|" "$LAYOUT_FILE"
fi

# --- Ensure package.json scripts ---
echo "📝 Ensuring package.json scripts..."
jq '.scripts.build="next build" | .scripts["vercel-build"]="next build" | .scripts.dev="next dev" | .scripts.start="next start"' package.json > package.tmp.json
mv package.tmp.json package.json

# --- Install dependencies fresh ---
echo "📥 Installing dependencies..."
npm install --no-audit --no-fund

# --- Build locally ---
echo "🏗️ Building project..."
npm run build

# --- Deploy to Vercel ---
if [ -z "$VERCEL_TOKEN" ]; then
  echo "⚠️ VERCEL_TOKEN not set. Set it with 'export VERCEL_TOKEN=your_token_here'"
  exit 1
fi

echo "🚀 Deploying to Vercel..."
vercel --prod --yes --token "$VERCEL_TOKEN"

echo "✅ Deployment complete!"
