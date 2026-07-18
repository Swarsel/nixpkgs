{
  lib,
  stdenv,
  fetchFromGitHub,
  bash-completion,
  blueprint-compiler,
  dbus,
  dbus-glib,
  fish,
  gdk-pixbuf,
  glib,
  gobject-introspection,
  gtk4,
  gtk4-layer-shell,
  gvfs,
  json-glib,
  libadwaita,
  libgee,
  libnotify,
  libpulseaudio,
  librsvg,
  meson,
  ninja,
  nix-update-script,
  pantheon,
  pkg-config,
  python3,
  sassc,
  scdoc,
  testers,
  vala,
  wayland-scanner,
  wrapGAppsHook3,
  xvfb-run,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "SwayNotificationCenter";
  version = "0.12.6";

  src = fetchFromGitHub {
    owner = "ErikReider";
    repo = "SwayNotificationCenter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-U5jsH2hSMTNMCtmo+lIXunam4M+B3xxMQU1SM3ZK5X0=";
  };

  postPatch = ''
    chmod +x build-aux/meson/postinstall.py
    patchShebangs build-aux/meson/postinstall.py
    substituteInPlace src/functions.vala --replace "/usr/local/etc/xdg/swaync" "$out/etc/xdg/swaync"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    bash-completion
    blueprint-compiler
    # cmake # currently conflicts with meson
    fish
    glib
    gobject-introspection
    meson
    ninja
    pkg-config
    python3
    sassc
    scdoc
    vala
    wayland-scanner
    wrapGAppsHook3
  ];

  buildInputs = [
    dbus
    dbus-glib
    gdk-pixbuf
    glib
    gtk4-layer-shell
    gtk4
    gvfs
    json-glib
    libadwaita
    libgee
    libnotify
    libpulseaudio
    librsvg
    pantheon.granite7
    # systemd # ends with broken permission
  ];

  # build pkg-config is required to locate the native `scdoc` input
  depsBuildBuild = [ pkg-config ];

  passthru.tests.version = testers.testVersion {
    command = "${xvfb-run}/bin/xvfb-run swaync --version";
    package = finalAttrs.finalPackage;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Simple notification daemon with a GUI built for Sway";
    homepage = "https://github.com/ErikReider/SwayNotificationCenter";
    changelog = "https://github.com/ErikReider/SwayNotificationCenter/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      berbiche
      pedrohlc
    ];

    platforms = lib.platforms.linux;
    mainProgram = "swaync";
  };
})
