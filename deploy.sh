#!/bin/bash
set -e

# Navigate to project
cd "$(dirname "$0")"

# Check if VERCEL_TOKEN is set
if [ -z "$VERCEL_TOKEN" ]; then
    echo "⚠️  Please export VERCEL_TOKEN before running deploy:"
    echo "export VERCEL_TOKEN=your_real_vercel_token_here"
    exit 1
fi

# Deploy to Vercel
echo "🔹 Deploying NexaCore to Vercel..."
GIT_CONFIG_GLOBAL=/dev/null \
GIT_CONFIG_SYSTEM=/dev/null \
GIT_TERMINAL_PROMPT=0 \
HOME=$PWD \
vercel --prod --yes --token "$VERCEL_TOKEN"

echo "✅ NexaCore deployment complete!"
