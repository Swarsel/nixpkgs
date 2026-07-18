{
  lib,
  stdenv,
  fetchFromGitLab,
  buildPackages,
  gettext,
  gitUpdater,
  gobject-introspection,
  gtk3,
  libxfce4ui,
  libxfce4util,
  pkg-config,
  xfce4-dev-tools,
  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "garcon";
  version = "4.20.0";

  src = fetchFromGitLab {
    owner = "xfce";
    repo = "garcon";
    tag = "garcon-${finalAttrs.version}";
    hash = "sha256-MeZkDb2QgGMaloO6Nwlj9JmZByepd6ERqpAWqrVv1xw=";
    domain = "gitlab.xfce.org";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    gettext
    pkg-config
    xfce4-dev-tools
  ]
  ++ lib.optionals withIntrospection [
    gobject-introspection
  ];

  buildInputs = [
    gtk3
    libxfce4ui
    libxfce4util
  ];

  configureFlags = [ "--enable-maintainer-mode" ];
  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "garcon-";
  };

  meta = {
    description = "Xfce menu support library";
    homepage = "https://gitlab.xfce.org/xfce/garcon";

    license = with lib.licenses; [
      lgpl2Only
      fdl11Only
    ];

    platforms = lib.platforms.linux;
    teams = [ lib.teams.xfce ];
  };
})
