#!/bin/bash
set -e

PROJECT_DIR="$HOME/nexacore"
cd "$PROJECT_DIR"

echo "🔹 Cleaning duplicate lockfiles..."
find . -name "package-lock.json" -not -path "$PROJECT_DIR/package-lock.json" -exec rm -f {} \;

echo "🔹 Updating Next.js, React, and React DOM to latest versions..."
npm install next@latest react@latest react-dom@latest

echo "🔹 Forcing Next.js to use Webpack instead of Turbopack..."
CONFIG_FILE="next.config.js"
cat > "$CONFIG_FILE" << CONFIG_EOF
/** @type {import('next').NextConfig} */
module.exports = {
  experimental: {
    turbo: false
  },
  webpack: (config) => config
}
CONFIG_EOF

echo "🔹 Checking package.json versions..."
grep '"next"\|"react"\|"react-dom"' package.json || true

echo "🔹 Building project with Webpack..."
NEXT_PRIVATE_SKIP_TURBOPACK=1 npm run build

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

echo "✅ Update and deployment complete!"
