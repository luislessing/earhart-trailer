# lastline — XFCE rice

Ein echtes, installierbares Arch/XFCE-Rice für den Trailer: dunkel, flach,
minimalistisch — keine Terminal-/Hacker-Ästhetik. Panel oben (Whisker-Menü,
Workspaces, Fensterliste, Tray), Materia-dark + Papirus-Dark als Theme,
ein Firefox-Profil mit lokaler Forum-Startseite, ein paar Desktop-Dateien
und Notizen mit geschwärzten Stellen.

Alle Pakete kommen aus den offiziellen Arch-Repos (`core`/`extra`) — kein
AUR-Helper nötig.

## Voraussetzung

Eine **frische, separate** Arch-Installation (Rechner, kein Hypervisor
nötig), die nur für den Dreh existiert. Ein headless-installiertes System
reicht als Basis völlig aus — X-Server, XFCE, Display-Manager, Theme,
Firefox: alles davon installiert `install.sh` selbst. Vorausgesetzt wird
nur, was ein minimales `pacstrap`/`archinstall` normalerweise schon
mitbringt:

- ein normaler Benutzer mit `sudo`-Rechten (nicht root — das Skript
  bricht als root bewusst ab) und funktionierendes Netzwerk für `pacman`.
- ein `mesa`-taugliches Grafikkarten-Setup (Intel/AMD werden vom
  `modesetting`-Treiber + `mesa` automatisch erkannt, das installiert
  das Skript mit). Bei Nvidia mit proprietärem Treiber sag Bescheid,
  dann ergänze ich `nvidia`/`nvidia-utils` statt `mesa`.

Das Skript installiert Pakete, setzt den Hostnamen auf `lastline` und
schreibt Configs unter `~/.config` — nichts davon ist für ein
Alltagssystem gedacht.

## Installation

```sh
# xfce-rice/ auf die Zielmaschine kopieren, dann:
cd xfce-rice
./install.sh
```

Das Skript läuft als normaler User (nicht root) und nutzt `sudo` nur für
`pacman` und `systemctl`/`hostnamectl`. Am Ende: neu starten (oder
`sudo systemctl start lightdm`), einloggen, fertig.

Falls das Panel nach dem ersten Login noch wie Standard-Xfce aussieht:
einmal aus- und wieder einloggen — xfconf liest XML, das vor dem ersten
Start reingelegt wurde, manchmal erst beim zweiten Login sauber ein.

## Was dabei rauskommt

- **Panel oben**: Whisker-Menü, Workspace-Pager (4 Workspaces), Fensterliste,
  Lautstärke, Benachrichtigungen, Uhr (`Fr 07. Aug · 03:47`-Format).
- **Theme**: Materia-dark (GTK + xfwm4) + Papirus-Dark Icons. Eine kleine
  `gtk.css` schiebt Materias Teal-Akzent Richtung gedecktes Rot
  (`#b1483d`) — Best-effort, siehe Kommentar in der Datei.
- **picom**: nur weiche Schatten + leicht abgerundete Ecken, kein Blur,
  kein Fading — sonst sieht es zu sehr nach "Rice-Screenshot" aus.
- **Wallpaper**: `wallpaper/lastline.png`, fast einfarbig dunkel mit
  Punktraster, kaum sichtbaren Radar-Bögen und Filmkorn (gegen Banding).
  Neu generieren / anpassen: `python3 wallpaper/generate_wallpaper.py`.
- **Desktop**: Ordner „THE ARCHIVE" (enthält die Forum-Startseite),
  `notes.txt` (geschwärzter Text), `EVIDENCE.zip`, Ordner „DISCARDED".
- **Firefox**: eigenes Profil `lastline`, dunkles UI, keine
  Onboarding-/Update-Popups, Startseite = die lokale Forum-Seite
  (`THE ARCHIVE/index.html`, offline, kein Netzwerk nötig).

## Euer echtes Forum einbinden

`skel/Desktop/THE ARCHIVE/index.html` ist aktuell ein Platzhalter-Mockup.
Sobald eure echte Forum-Seite eine URL hat:

- entweder `browser.startup.homepage` in `firefox/user.js` auf die echte
  URL setzen (dann braucht es Netzwerk beim Dreh), oder
- die echte Seite als statischen Export in `skel/Desktop/THE ARCHIVE/`
  ablegen, damit es offline bleibt.

## Checkliste vor dem Drehen

- **Netzwerk**: `nmcli networking off` (oder Kabel/WLAN aus) — das Tray-Icon
  zeigt dann ehrlich "getrennt", keine Attrappe nötig.
- **Uhrzeit im Panel**: zeigt die echte Systemzeit. Für den 03:47-Look:
  `sudo timedatectl set-ntp false && sudo timedatectl set-time "03:47"`
  (danach `set-ntp true` nicht vergessen, sonst bleibt die Uhr falsch).
- **Fenster arrangieren**: Browser groß/vorne, Mousepad mit `notes.txt`
  dahinter leicht versetzt öffnen — genau wie im HTML-Mockup, das als
  Vorlage dient.
- Bildschirmschoner/Sperre aus, falls die Aufnahme länger dauert:
  Einstellungen → Energieverwaltung / Bildschirmschoner.

## Troubleshooting: bleibt bei Text-Login hängen / `cannot open display`

Passiert, wenn das System nach dem Neustart weiter im Text-Modus bootet
statt grafisch — `systemctl enable lightdm` reicht dafür allein nicht,
es startet lightdm nur, *wenn* `graphical.target` erreicht wird. Prüfen:

```sh
systemctl get-default          # sollte "graphical.target" ausgeben
sudo systemctl set-default graphical.target
sudo systemctl isolate graphical.target   # sofort testen, ohne Reboot
```

Kommt danach immer noch kein Greeter, die eigentliche Fehlerursache holen:

```sh
systemctl status lightdm --no-pager
journalctl -u lightdm -b --no-pager | tail -60
cat /var/log/Xorg.0.log 2>/dev/null | tail -60 || cat ~/.local/share/xorg/Xorg.0.log | tail -60
```

## Troubleshooting: Login "erfolgreich", aber Bildschirm springt sofort zurück

`journalctl -b` zeigt eine Session, die nach <1s wieder geschlossen wird,
oft mit `type 'wayland'`. Ursache: `xfce4-session` bringt neben der
normalen X11-Session (`/usr/share/xsessions/xfce.desktop`) eine
experimentelle `xfce-wayland.desktop` unter
`/usr/share/wayland-sessions/` mit. Ohne installierten Wayland-Compositor
stirbt die sofort. Wenn der Greeter die beim allerersten Login als
Standard vorschlägt (und `~/.dmrc` das dann speichert), landet man in
einer Schleife, die aussieht, als würde der Login gar nicht klappen.

Das passiert unabhängig davon, wie XFCE installiert wurde — auch mit
`archinstall`s eigenem Xfce4-Profil, ganz ohne `install.sh`, weil die
Datei aus dem `xfce4-session`-Paket selbst kommt.

`install.sh` behebt das inzwischen doppelt: `user-session=xfce` global
über `/etc/lightdm/lightdm.conf.d/50-lastline.conf` (falls lightdm zum
Einsatz kommt) und zusätzlich wird die Wayland-Sitzung komplett
deaktiviert, damit sie auf keinem Display-Manager (lightdm/sddm/gdm)
mehr angeboten werden kann. Bei einer bereits installierten Maschine von
Hand nachziehen — der zweite Befehl ist der eigentlich robuste, weil er
unabhängig vom Display-Manager funktioniert:

```sh
sudo mv /usr/share/wayland-sessions/xfce-wayland.desktop \
        /usr/share/wayland-sessions/xfce-wayland.desktop.disabled
rm -f ~/.dmrc
sudo systemctl restart display-manager
```

## Schnelles Iterieren ohne Neustart

```sh
xfce4-panel -r          # Panel neu laden nach Änderungen an xfce4-panel.xml
xfwm4 --replace &        # Fenstermanager/Theme neu laden
xfdesktop --reload       # Wallpaper/Desktop-Icons neu laden
```

## Akzentfarbe ändern

`#b1483d` taucht in `config/gtk.css`, `firefox/userChrome.css`,
`skel/Desktop/THE ARCHIVE/index.html` und `wallpaper/generate_wallpaper.py`
auf — überall gleich ersetzen.
