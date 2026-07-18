{
  lib,
  stdenv,
  fetchFromGitLab,
  buildPackages,
  gettext,
  gitUpdater,
  gobject-introspection,
  gtk3,
  libepoxy,
  libgtop,
  libgudev,
  libice,
  libsm,
  libstartup_notification,
  libxfce4util,
  perl,
  pkg-config,
  vala,
  wrapGAppsHook3,
  xfce4-dev-tools,
  xfconf,
  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libxfce4ui";
  version = "4.20.2";

  src = fetchFromGitLab {
    owner = "xfce";
    repo = "libxfce4ui";
    tag = "libxfce4ui-${finalAttrs.version}";
    hash = "sha256-NsTrJ2271v8vMMyiEef+4Rs0KBOkSkKPjfoJdgQU0ds=";
    domain = "gitlab.xfce.org";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    gettext
    perl
    pkg-config
    xfce4-dev-tools
    wrapGAppsHook3
  ]
  ++ lib.optionals withIntrospection [
    gobject-introspection
    vala # vala bindings require GObject introspection
  ];

  buildInputs = [
    libice
    libsm
    libepoxy
    libgtop
    libgudev
    libstartup_notification
    xfconf
  ];

  propagatedBuildInputs = [
    gtk3
    libxfce4util
  ];

  configureFlags = [
    "--enable-maintainer-mode"
    "--with-vendor-info=NixOS"
  ];

  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "libxfce4ui-";
  };

  meta = {
    description = "Widgets library for Xfce";
    homepage = "https://gitlab.xfce.org/xfce/libxfce4ui";

    license = with lib.licenses; [
      lgpl2Plus
      lgpl21Plus
    ];

    platforms = lib.platforms.linux;
    mainProgram = "xfce4-about";
    teams = [ lib.teams.xfce ];
  };
})
