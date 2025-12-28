#!/bin/bash
set -e

# Backup original package.json
cp package.json package.json.bak

# Ensure "scripts" exists and add required scripts
jq 'if .scripts then . else . + {scripts:{}} end
    | .scripts += {
        "vercel-build":"next build",
        "dev":"next dev",
        "start":"next start"
      }
    | . + {"type":"module"}' package.json > package.tmp.json

mv package.tmp.json package.json
echo "✅ package.json updated!"
