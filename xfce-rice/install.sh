#!/usr/bin/env bash
# lastline — a dark, flat XFCE rice for the trailer shoot.
#
# Run this AS THE USER who will log in and be filmed (not root).
# Target: a fresh Arch install, dedicated to this shoot.
#
#   git clone / copy this xfce-rice/ folder onto the VM, then:
#   cd xfce-rice && ./install.sh
#
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

if [[ $EUID -eq 0 ]]; then
  echo "Run this as your normal user, not root — it uses sudo where needed." >&2
  exit 1
fi

RICE_HOME="$HOME"
SET_HOSTNAME=true
HOSTNAME_LABEL="lastline"

echo "==> installing packages (official repos only, no AUR needed)"
XFCE_CORE=(exo garcon thunar thunar-volman tumbler xfce4-appfinder
           xfce4-panel xfce4-power-manager xfce4-session xfce4-settings
           xfce4-terminal xfconf xfdesktop xfwm4)
XFCE_GOODIES=(mousepad ristretto thunar-archive-plugin xarchiver
              xfce4-notifyd xfce4-pulseaudio-plugin
              xfce4-whiskermenu-plugin xfce4-screenshooter)
BASE=(xorg-server xorg-xinit xorg-xrandr mesa lightdm lightdm-gtk-greeter
      networkmanager network-manager-applet)
THEME=(materia-gtk-theme papirus-icon-theme adwaita-icon-theme
       inter-font ttf-jetbrains-mono)
APPS=(firefox picom zip unzip)

sudo pacman -S --needed --noconfirm \
  "${XFCE_CORE[@]}" "${XFCE_GOODIES[@]}" "${BASE[@]}" "${THEME[@]}" "${APPS[@]}"

echo "==> enabling the display manager (starts on next boot)"
sudo systemctl enable lightdm.service

if $SET_HOSTNAME; then
  echo "==> setting hostname to ${HOSTNAME_LABEL}"
  sudo hostnamectl set-hostname "$HOSTNAME_LABEL"
fi

echo "==> wallpaper"
mkdir -p "$RICE_HOME/.local/share/backgrounds"
cp wallpaper/lastline.png "$RICE_HOME/.local/share/backgrounds/lastline.png"

echo "==> xfconf (panel, desktop, window manager, xsettings)"
XFCONF_DIR="$RICE_HOME/.config/xfce4/xfconf/xfce-perchannel-xml"
mkdir -p "$XFCONF_DIR"
for f in config/xfce4-panel.xml config/xsettings.xml config/xfwm4.xml; do
  cp "$f" "$XFCONF_DIR/$(basename "$f")"
done
sed "s#__HOME__#$RICE_HOME#g" config/xfce4-desktop.xml > "$XFCONF_DIR/xfce4-desktop.xml"

echo "==> gtk accent override"
mkdir -p "$RICE_HOME/.config/gtk-3.0"
cp config/gtk.css "$RICE_HOME/.config/gtk-3.0/gtk.css"

echo "==> picom (subtle shadows, no blur/fade)"
cp config/picom.conf "$RICE_HOME/.config/picom.conf"
mkdir -p "$RICE_HOME/.config/autostart"
cat > "$RICE_HOME/.config/autostart/picom.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=picom
Exec=picom
X-GNOME-Autostart-enabled=true
EOF

echo "==> desktop files (THE ARCHIVE, notes.txt, EVIDENCE.zip, DISCARDED)"
mkdir -p "$RICE_HOME/Desktop"
cp -rn skel/Desktop/. "$RICE_HOME/Desktop/"
( cd skel/evidence_src && zip -qr "$RICE_HOME/Desktop/EVIDENCE.zip" . )

echo "==> firefox: dedicated 'lastline' profile, dark, quiet, offline homepage"
firefox -CreateProfile "lastline $RICE_HOME/.mozilla/firefox/lastline" >/dev/null 2>&1 || true
PROFILE_DIR="$RICE_HOME/.mozilla/firefox/lastline"
mkdir -p "$PROFILE_DIR/chrome"
cp firefox/userChrome.css "$PROFILE_DIR/chrome/userChrome.css"
HOMEPAGE_URL="file://$RICE_HOME/Desktop/THE%20ARCHIVE/index.html"
sed "s#__HOMEPAGE__#$HOMEPAGE_URL#g" firefox/user.js > "$PROFILE_DIR/user.js"

mkdir -p "$RICE_HOME/.local/share/applications"
cat > "$RICE_HOME/.local/share/applications/truth-browser.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Truth Browser
Comment=THE ARCHIVE
Exec=firefox -P lastline %U
Icon=firefox
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
Terminal=false
StartupNotify=true
EOF
update-desktop-database "$RICE_HOME/.local/share/applications" 2>/dev/null || true
xdg-settings set default-web-browser truth-browser.desktop 2>/dev/null || true

echo
echo "done. next steps:"
echo "  1. reboot (or: sudo systemctl start lightdm)"
echo "  2. log in, choose the Xfce session if asked"
echo "  3. panel/theme should already be in place — if the panel looks"
echo "     like stock Xfce, log out and back in once more (xfconf is"
echo "     sometimes slow to pick up XML dropped in before first login)"
echo
echo "before you hit record, see README.md's filming checklist."
