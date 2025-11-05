#!/bin/bash
# 📦 Script de mise à jour de version pour Manounou
# Usage: ./ops/version-bump.sh [major|minor|patch|build]
# Exemples:
#   ./ops/version-bump.sh patch    # 1.0.0 -> 1.0.1
#   ./ops/version-bump.sh minor    # 1.0.0 -> 1.1.0
#   ./ops/version-bump.sh build    # 1.0.0+1 -> 1.0.0+2

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 [major|minor|patch|build]"
    exit 1
fi

TYPE=$1
PUBSPEC="flutterflow_export/pubspec.yaml"

# Lire la version actuelle
CURRENT_VERSION=$(grep '^version:' "$PUBSPEC" | sed 's/version: //' | sed 's/\+.*//')
CURRENT_BUILD=$(grep '^version:' "$PUBSPEC" | sed 's/.*+//')

IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]}

# Calculer la nouvelle version
case $TYPE in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        NEW_BUILD=1
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        NEW_BUILD=1
        ;;
    patch)
        PATCH=$((PATCH + 1))
        NEW_BUILD=1
        ;;
    build)
        NEW_BUILD=$((CURRENT_BUILD + 1))
        ;;
    *)
        echo "Type invalide: $TYPE (utilisez major, minor, patch ou build)"
        exit 1
        ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"
if [ "$TYPE" != "build" ]; then
    NEW_VERSION_FULL="$NEW_VERSION+$NEW_BUILD"
else
    NEW_VERSION_FULL="$CURRENT_VERSION+$NEW_BUILD"
fi

# Mettre à jour pubspec.yaml
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/^version: .*/version: $NEW_VERSION_FULL/" "$PUBSPEC"
else
    # Linux
    sed -i "s/^version: .*/version: $NEW_VERSION_FULL/" "$PUBSPEC"
fi

echo "✅ Version mise à jour: $CURRENT_VERSION+$CURRENT_BUILD -> $NEW_VERSION_FULL"
echo ""
echo "📝 Prochaines étapes:"
echo "  1. git add $PUBSPEC"
echo "  2. git commit -m 'chore: bump version to $NEW_VERSION_FULL'"
echo "  3. git tag v$NEW_VERSION"
echo "  4. git push origin main --tags"

