#!/bin/bash
set -e

# 1️⃣ Define paths
OLD_DIR="$HOME/smartconnect-betting"
NEW_DIR="$HOME/nexacore"

echo "🔹 Creating NexaCore directory..."
mkdir -p "$NEW_DIR"
cd "$NEW_DIR"

# 2️⃣ Copy old project files (excluding node_modules, __pycache__, build, .cache)
echo "🔹 Copying NexaCore files..."
shopt -s extglob
for f in "$OLD_DIR"/*; do
    base=$(basename "$f")
    if [[ "$base" != "node_modules" && "$base" != "__pycache__" && "$base" != "build" && "$base" != ".cache" ]]; then
        cp -r "$f" "$NEW_DIR/"
    fi
done
shopt -u extglob

# 3️⃣ Rename NexaCore to NexaCore in all files
echo "🔹 Renaming NexaCore to NexaCore in project files..."
grep -rl "NexaCore" . | while read -r file; do
    sed -i 's/NexaCore/NexaCore/g' "$file"
done

# 4️⃣ Setup Firebase placeholder
mkdir -p lib
cat << 'FIREBASE' > lib/firebaseAdmin.js
import admin from 'firebase-admin';

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT))
  });
}

export const db = admin.firestore();
FIREBASE

# 5️⃣ Initialize package.json if missing
if [ ! -f package.json ]; then
    echo "🔹 Initializing package.json..."
    npm init -y
fi

# 6️⃣ Ensure Next.js and React are installed
npm install next react react-dom

# 7️⃣ Update package.json scripts
jq '.scripts.vercel-build="next build" | .scripts.dev="next dev" | .scripts.start="next start" | .type="module"' package.json > package.tmp.json
mv package.tmp.json package.json

# 8️⃣ Initialize Git (optional)
git init || true
git add .
git commit -m "NexaCore full migration" || true

# 9️⃣ Deploy to Vercel
if [ -z "$VERCEL_TOKEN" ]; then
    echo "⚠️  Please export VERCEL_TOKEN before running deploy: export VERCEL_TOKEN=your_token"
else
    echo "🔹 Deploying to Vercel..."
    GIT_CONFIG_GLOBAL=/dev/null \
    GIT_CONFIG_SYSTEM=/dev/null \
    GIT_TERMINAL_PROMPT=0 \
    HOME=$PWD \
    vercel --prod --yes --token "$VERCEL_TOKEN"
fi

echo "✅ NexaCore setup complete! Update your Firebase env and test the site."
