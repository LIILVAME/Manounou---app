#!/bin/bash

# Script pour lancer Manounou sur iOS
# Usage: ./run_ios.sh

cd "$(dirname "$0")/flutterflow_export"

echo "🔍 Recherche des simulateurs iOS disponibles..."
DEVICES=$(flutter devices | grep "iPhone" | grep "simulator" | head -1)

if [ -z "$DEVICES" ]; then
    echo "❌ Aucun simulateur iOS trouvé."
    echo "💡 Ouvrez Xcode > Window > Devices and Simulators pour créer un simulateur"
    exit 1
fi

# Extraire l'ID du simulateur (première colonne après le nom)
SIMULATOR_ID=$(echo "$DEVICES" | awk '{print $NF}')

echo "📱 Lancement sur simulateur: $DEVICES"
echo "🚀 Démarrage de l'application..."

flutter run -d "$SIMULATOR_ID"

