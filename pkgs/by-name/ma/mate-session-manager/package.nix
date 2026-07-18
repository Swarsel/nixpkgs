{
  lib,
  stdenv,
  fetchurl,
  dbus-glib,
  fetchpatch,
  gettext,
  gitUpdater,
  glib,
  gtk3,
  hicolor-icon-theme,
  libepoxy,
  libsm,
  libxtst,
  mate-desktop,
  mate-screensaver,
  pkg-config,
  polkit,
  systemd,
  wrapGAppsHook3,
  xtrans,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mate-session-manager";
  version = "1.28.0";

  src = fetchurl {
    url = "https://pub.mate-desktop.org/releases/${lib.versions.majorMinor finalAttrs.version}/mate-session-manager-${finalAttrs.version}.tar.xz";
    sha256 = "0yzkWVuh2mUpB3cgPyvIK9lzshSjoECAoe9caJkKLXs=";
  };

  patches = [
    # allow turning on debugging from environment variable
    (fetchpatch {
      sha256 = "0yjaklq0mp44clymyhy240kxlw95z3azmravh4f5pfm9dys33sg0";
      url = "https://github.com/mate-desktop/mate-session-manager/commit/3ab6fbfc811d00100d7a2959f8bbb157b536690d.patch";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    gettext
    xtrans
    wrapGAppsHook3
  ];

  buildInputs = [
    dbus-glib
    systemd
    libsm
    libxtst
    gtk3
    mate-desktop
    mate-screensaver # for gsm_manager_init
    hicolor-icon-theme
    libepoxy
    polkit
  ];

  env.NIX_CFLAGS_COMPILE = "-I${glib.dev}/include/gio-unix-2.0";

  postFixup = ''
    substituteInPlace $out/share/xsessions/mate.desktop \
      --replace-fail "Exec=mate-session" "Exec=$out/bin/mate-session"
  '';

  enableParallelBuilding = true;
  passthru.providedSessions = [ "mate" ];

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "v";
    url = "https://git.mate-desktop.org/mate-session-manager";
  };

  meta = {
    description = "MATE Desktop session manager";
    homepage = "https://github.com/mate-desktop/mate-session-manager";

    license = with lib.licenses; [
      gpl2Plus
      lgpl2Plus
    ];

    platforms = lib.platforms.unix;
    teams = [ lib.teams.mate ];
  };
})
