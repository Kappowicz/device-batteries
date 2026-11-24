#!/usr/bin/env bash
# Installs the script and widget into the home directory (survives SteamOS updates)
# and adds the widget to the first Plasma panel.
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
    print(found ? "Widget is already on the panel" : "Widget added to the panel");'
else
  echo "qdbus not found: add the widget manually (right-click the panel → Add Widgets → \"Device Batteries\")."
fi

echo "Test:"
"$HOME/.local/bin/device-batteries"
