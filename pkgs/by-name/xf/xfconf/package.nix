{
  lib,
  stdenv,
  fetchFromGitLab,
  buildPackages,
  gettext,
  gitUpdater,
  glib,
  gobject-introspection,
  libxfce4util,
  perl,
  pkg-config,
  vala,
  wrapGAppsNoGuiHook,
  xfce4-dev-tools,
  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfconf";
  version = "4.20.0";

  src = fetchFromGitLab {
    owner = "xfce";
    repo = "xfconf";
    tag = "xfconf-${finalAttrs.version}";
    hash = "sha256-U+Sk7ubBr1ZD1GLQXlxrx0NQdhV/WpVBbnLcc94Tjcw=";
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
    wrapGAppsNoGuiHook
  ]
  ++ lib.optionals withIntrospection [
    gobject-introspection
    vala # vala bindings require GObject introspection
  ];

  buildInputs = [ libxfce4util ];
  propagatedBuildInputs = [ glib ];
  configureFlags = [ "--enable-maintainer-mode" ];
  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "xfconf-";
  };

  meta = {
    description = "Simple client-server configuration storage and query system for Xfce";
    homepage = "https://gitlab.xfce.org/xfce/xfconf";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "xfconf-query";
    teams = [ lib.teams.xfce ];
  };
})
