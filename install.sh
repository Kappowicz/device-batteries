#!/usr/bin/env bash
# Instaluje skrypt i widżet do katalogu domowego (przetrwa aktualizacje SteamOS)
# i dodaje widżet na pierwszy panel Plasmy.
set -euo pipefail
cd "$(dirname "$0")"

install -Dm755 device-batteries "$HOME/.local/bin/device-batteries"

dest="$HOME/.local/share/plasma/plasmoids/org.local.devicebatteries"
rm -rf "$dest"
mkdir -p "$(dirname "$dest")"
cp -r plasmoid/org.local.devicebatteries "$dest"

qdbus=$(command -v qdbus6 || command -v qdbus || true)
if [ -n "$qdbus" ]; then
  "$qdbus" org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '
    var p = panels()[0], found = false;
    p.widgets().forEach(function (w) { if (w.type == "org.local.devicebatteries") found = true; });
    if (!found) p.addWidget("org.local.devicebatteries");
    print(found ? "Widżet już jest na panelu" : "Dodano widżet na panel");'
else
  echo "Brak qdbus: dodaj widżet ręcznie (prawy klik na panel → Dodaj widżety → \"Baterie urządzeń\")."
fi

echo "Test:"
"$HOME/.local/bin/device-batteries"
