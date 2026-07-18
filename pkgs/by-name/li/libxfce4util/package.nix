{
  lib,
  stdenv,
  fetchFromGitLab,
  buildPackages,
  gettext,
  gitUpdater,
  glib,
  gobject-introspection,
  pkg-config,
  python3,
  vala,
  wrapGAppsNoGuiHook,
  xfce4-dev-tools,
  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libxfce4util";
  version = "4.20.1";

  src = fetchFromGitLab {
    owner = "xfce";
    repo = "libxfce4util";
    tag = "libxfce4util-${finalAttrs.version}";
    hash = "sha256-QlT5ev4NhjR/apbgYQsjrweJ2IqLySozLYLzCAnmkfM=";
    domain = "gitlab.xfce.org";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    patchShebangs xdt-gen-visibility
  '';

  nativeBuildInputs = [
    gettext
    pkg-config
    python3
    xfce4-dev-tools
    wrapGAppsNoGuiHook
  ]
  ++ lib.optionals withIntrospection [
    gobject-introspection
    vala # vala bindings require GObject introspection
  ];

  propagatedBuildInputs = [
    glib
  ];

  configureFlags = [ "--enable-maintainer-mode" ];
  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "libxfce4util-";
  };

  meta = {
    description = "Extension library for Xfce";
    homepage = "https://gitlab.xfce.org/xfce/libxfce4util";
    license = lib.licenses.lgpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "xfce4-kiosk-query";
    teams = [ lib.teams.xfce ];
  };
})
