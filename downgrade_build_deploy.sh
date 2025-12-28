#!/bin/bash
set -e

PROJECT_DIR="$HOME/nexacore"
cd "$PROJECT_DIR"

echo "🔹 Cleaning duplicate lockfiles..."
find . -name "package-lock.json" -not -path "$PROJECT_DIR/package-lock.json" -exec rm -f {} \;

echo "🔹 Downgrading Next.js to 15.x and installing compatible React..."
npm install next@15 react@18 react-dom@18

echo "🔹 Checking package.json versions..."
grep '"next"\|"react"\|"react-dom"' package.json || true

echo "🔹 Building project with Webpack (no Turbopack)..."
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

echo "✅ Build and deployment complete!"
