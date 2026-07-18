{
  lib,
  fetchFromGitHub,
  haskellPackages,
  mkDerivation,
}:

let
  # deadd-notification-center.service
  systemd-service = ''
    [Unit]
    Description=Deadd Notification Center
    PartOf=graphical-session.target

    [Service]
    Type=dbus
    BusName=org.freedesktop.Notifications
    ExecStart=$out/bin/deadd-notification-center

    [Install]
    WantedBy=graphical-session.target
  '';
in
mkDerivation rec {
  pname = "deadd-notification-center";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "phuhl";
    repo = "linux_notification_center";
    rev = version;
    hash = "sha256-VU9NaQVS0n8hFRjWMvCMkaF5mZ4hpnluV31+/SAK7tU=";
  };

  postPatch = ''
    substituteInPlace src/NotificationCenter.hs \
      --replace '/etc/xdg/deadd/deadd.css' "$out/etc/deadd.css"
  '';

  # Test suite does nothing.
  doCheck = false;

  # Add systemd user unit and install default style.
  postInstall = ''
    mkdir -p $out/lib/systemd/user
    install -Dm644 style.css $out/etc/deadd.css
    echo "${systemd-service}" > $out/lib/systemd/user/deadd-notification-center.service
  '';

  description = "Haskell-written notification center for users that like a desktop with style";
  executableHaskellDepends = with haskellPackages; [ base ];
  homepage = "https://github.com/phuhl/linux_notification_center";
  isExecutable = true;
  isLibrary = false;

  libraryHaskellDepends = with haskellPackages; [
    aeson
    base
    bytestring
    ConfigFile
    containers
    dbus
    directory
    env-locale
    filepath
    gi-cairo
    gi-gdk
    gi-gdkpixbuf
    gi-gio
    gi-glib
    gi-gobject
    gi-gtk
    gi-pango
    haskell-gettext
    haskell-gi
    haskell-gi-base
    hdaemonize
    here
    lens
    mtl
    process
    regex-tdfa
    setlocale
    split
    stm
    tagsoup
    text
    time
    transformers
    tuple
    unix
    yaml
  ];

  license = lib.licenses.bsd3;
  mainProgram = "deadd-notification-center";

  maintainers = with lib.maintainers; [
    melkor333
    sna
  ];

  platforms = lib.platforms.linux;
}
