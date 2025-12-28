#!/bin/bash
set -e

cd ~/nexacore

# Remove Turbopack and lockfiles
rm -rf node_modules package-lock.json
npm cache clean --force

# Install compatible versions
npm install next@15.4.2 react@18.2.0 react-dom@18.2.0
npm install tailwindcss@3.3.3 postcss@8.4.27 autoprefixer@10.4.15

# Force Webpack config
cat > next.config.cjs << 'EOM'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true
};
module.exports = nextConfig
EOM

# Ensure scripts in package.json
jq '.scripts.build="next build" | .scripts.dev="next dev" | .scripts.start="next start"' package.json > package.tmp.json
mv package.tmp.json package.json

# Install dependencies and build
npm install
npm run build

# Deploy if token is set
if [ -n "$VERCEL_TOKEN" ]; then
  GIT_CONFIG_GLOBAL=/dev/null \
  GIT_CONFIG_SYSTEM=/dev/null \
  GIT_TERMINAL_PROMPT=0 \
  HOME=$PWD \
  vercel --prod --yes --token "$VERCEL_TOKEN"
fi

echo "✅ Build + deployment finished!"
