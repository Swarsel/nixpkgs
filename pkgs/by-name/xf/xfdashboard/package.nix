{
  lib,
  stdenv,
  fetchFromGitLab,
  clutter,
  fetchpatch,
  garcon,
  gettext,
  gitUpdater,
  glib,
  gtk3,
  libwnck,
  libx11,
  libxcomposite,
  libxdamage,
  libxfce4ui,
  libxfce4util,
  libxinerama,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook3,
  xfconf,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfdashboard";
  version = "1.1.0";

  src = fetchFromGitLab {
    owner = "apps";
    repo = "xfdashboard";
    tag = "xfdashboard-${finalAttrs.version}";
    hash = "sha256-D8Tue+45CO5yy7sxealKQoFQZobCiDUzoxCsDksTTxI=";
    domain = "gitlab.xfce.org";
  };

  patches = [
    # Exit early if not on X11
    (fetchpatch {
      hash = "sha256-u0djTProV3On0uutg89Q+psgmVGJS768KwiYxZ7dhrE=";
      url = "https://gitlab.xfce.org/apps/xfdashboard/-/commit/7452a7074dfc36c5af42c4105aadaac8656c2f60.patch";
    })

    # build: Fix version/so_version inversion
    (fetchpatch {
      hash = "sha256-C2oIBi9tfoQF123Ez3YbFUs8vX2DeYdr3BDc85ExTgQ=";
      url = "https://gitlab.xfce.org/apps/xfdashboard/-/commit/20f23e62576d186fada6688af3bb05bc7f223f44.patch";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    gettext
    glib # glib-genmarshal
    meson
    ninja
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    clutter
    garcon
    glib
    gtk3
    libx11
    libxcomposite
    libxdamage
    libxinerama
    libwnck
    libxfce4ui
    libxfce4util
    xfconf
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "xfdashboard-"; };

  meta = {
    description = "GNOME shell like dashboard";
    homepage = "https://gitlab.xfce.org/apps/xfdashboard";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "xfdashboard";
    teams = [ lib.teams.xfce ];
  };
})
