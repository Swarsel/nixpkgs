{
  lib,
  stdenv,
  fetchFromGitHub,
  at-spi2-core,
  desktop-file-utils,
  gettext,
  gnome-desktop,
  gnome-settings-daemon,
  granite,
  granite7,
  gtk3,
  gtk4,
  libgee,
  libhandy,
  libxml2,
  meson,
  mutter,
  ninja,
  nix-update-script,
  pkg-config,
  sqlite,
  systemd,
  vala,
  wayland-scanner,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gala";
  version = "8.5.1";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "gala";
    tag = finalAttrs.version;
    hash = "sha256-f+/RaKG208v84q1V9NkDci0wuGAtXwjVsF7ITDAgHCQ=";
  };

  postPatch = ''
    substituteInPlace meson.build \
      --replace-fail "conf.set('PLUGINDIR', plugins_dir)" "conf.set('PLUGINDIR','/run/current-system/sw/lib/gala/plugins')"
  '';

  nativeBuildInputs = [
    desktop-file-utils
    gettext
    libxml2
    meson
    ninja
    pkg-config
    vala
    wayland-scanner
    wrapGAppsHook4
  ];

  buildInputs = [
    at-spi2-core
    gnome-settings-daemon
    gnome-desktop
    granite
    granite7
    gtk3 # daemon-gtk3
    gtk4
    libgee
    libhandy
    mutter
    sqlite
    systemd
  ];

  depsBuildBuild = [ pkg-config ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Window & compositing manager based on mutter and designed by elementary for use with Pantheon";
    homepage = "https://github.com/elementary/gala";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "gala";
    teams = [ lib.teams.pantheon ];
  };
})
