#!/bin/bash
set -e

cd ~/nexacore

# Ensure package.json exists
if [ ! -f package.json ]; then
    echo "⚠️ package.json not found!"
    exit 1
fi

# Backup original package.json
cp package.json package.json.bak

# Add necessary scripts and type
jq '
  .scripts.build="next build" |
  .scripts.dev="next dev" |
  .scripts.start="next start" |
  .scripts["vercel-build"]="next build" |
  .type="module"
' package.json > package.tmp.json && mv package.tmp.json package.json

echo "✅ package.json scripts updated!"
