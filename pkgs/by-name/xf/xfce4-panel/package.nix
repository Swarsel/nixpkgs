{
  lib,
  stdenv,
  fetchFromGitLab,
  buildPackages,
  cairo,
  garcon,
  gettext,
  gitUpdater,
  gobject-introspection,
  gtk-layer-shell,
  gtk3,
  libdbusmenu-gtk3,
  libwnck,
  libxfce4ui,
  libxfce4util,
  libxfce4windowing,
  pkg-config,
  python3,
  tzdata,
  vala,
  wayland,
  wrapGAppsHook3,
  xfce4-dev-tools,
  xfce4-exo,
  xfconf,
  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfce4-panel";
  version = "4.20.7";

  src = fetchFromGitLab {
    owner = "xfce";
    repo = "xfce4-panel";
    tag = "xfce4-panel-${finalAttrs.version}";
    hash = "sha256-tL32ymLhV1QK84223iEgGrKdZXm5/nB3MumDyDIrSHQ=";
    domain = "gitlab.xfce.org";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    patchShebangs xdt-gen-visibility

    substituteInPlace plugins/clock/clock.c \
       --replace-fail "/usr/share/zoneinfo" "${tzdata}/share/zoneinfo"
  '';

  nativeBuildInputs = [
    gettext
    pkg-config
    python3
    xfce4-dev-tools
    wrapGAppsHook3
  ]
  ++ lib.optionals withIntrospection [
    gobject-introspection
    vala # vala bindings require GObject introspection
  ];

  buildInputs = [
    cairo
    xfce4-exo
    garcon
    gtk-layer-shell
    libdbusmenu-gtk3
    libxfce4ui
    libxfce4windowing
    libwnck
    tzdata
    wayland
    xfconf
  ];

  propagatedBuildInputs = [
    gtk3
    libxfce4util
  ];

  configureFlags = [ "--enable-maintainer-mode" ];
  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "xfce4-panel-";
  };

  meta = {
    description = "Panel for the Xfce desktop environment";
    homepage = "https://gitlab.xfce.org/xfce/xfce4-panel";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "xfce4-panel";
    teams = [ lib.teams.xfce ];
  };
})
