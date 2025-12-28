#!/bin/bash
jq '.scripts["vercel-build"]="next build"' package.json > package.tmp.json
mv package.tmp.json package.json
