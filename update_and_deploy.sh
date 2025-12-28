#!/bin/bash
set -e

# Navigate to project
PROJECT_DIR="$HOME/nexacore"
cd "$PROJECT_DIR"

echo "🔹 Cleaning duplicate lockfiles..."
find . -name "package-lock.json" -not -path "$PROJECT_DIR/package-lock.json" -exec rm -f {} \;

echo "🔹 Updating Next.js, React, and React DOM to latest versions..."
npm install next@latest react@latest react-dom@latest

echo "🔹 Updating next.config.js to disable Turbopack..."
CONFIG_FILE="next.config.js"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "module.exports = { experimental: { turbo: false } };" > "$CONFIG_FILE"
else
    grep -q 'experimental.*turbo' "$CONFIG_FILE" || echo "module.exports = { experimental: { turbo: false } };" >> "$CONFIG_FILE"
fi

echo "🔹 Checking package.json versions..."
grep '"next"\|"react"\|"react-dom"' package.json

echo "🔹 Building project with Webpack..."
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

echo "✅ Update and deployment complete!"
