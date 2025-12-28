#!/bin/bash
set -e

# --- Clean old builds ---
echo "🧹 Cleaning old build artifacts..."
rm -rf .next

# --- Ensure VERCEL_TOKEN is set ---
if [ -z "$VERCEL_TOKEN" ]; then
  echo "⚠️ VERCEL_TOKEN not set. Run: export VERCEL_TOKEN=your_token_here"
  exit 1
fi

# --- Deploy using prebuilt build ---
echo "🚀 Deploying to Vercel (prebuilt)..."
vercel --prebuilt --prod --yes --token "$VERCEL_TOKEN"

echo "✅ Deployment attempt complete!"
