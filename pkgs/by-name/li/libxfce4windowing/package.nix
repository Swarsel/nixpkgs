{
  lib,
  stdenv,
  fetchFromGitLab,
  buildPackages,
  gettext,
  gitUpdater,
  glib,
  gobject-introspection,
  gtk3,
  libdisplay-info,
  libwnck,
  libx11,
  libxrandr,
  meson,
  ninja,
  pkg-config,
  python3,
  vala,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wlr-protocols,
  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libxfce4windowing";
  version = "4.20.6";

  src = fetchFromGitLab {
    owner = "xfce";
    repo = "libxfce4windowing";
    tag = "libxfce4windowing-${finalAttrs.version}";
    hash = "sha256-lTOCvxUSo0CCok5nPCX7B6RqVoNMYcSb97alR+htBtY=";
    domain = "gitlab.xfce.org";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    # Headers depend on gtk3 but it is only listed in Requires.private,
    # which does not influence Cflags on non-static builds in nixpkgs’s
    # pkg-config. Let’s add it to Requires to ensure Cflags are set correctly.
    ./pkg-config-requires.patch
  ];

  postPatch = ''
    patchShebangs xdt-gen-visibility
  '';

  strictDeps = true;

  nativeBuildInputs = [
    gettext
    meson
    ninja
    pkg-config
    python3
    wayland-scanner
  ]
  ++ lib.optionals withIntrospection [
    gobject-introspection
    vala # vala bindings require GObject introspection
  ];

  buildInputs = [
    glib
    libdisplay-info
    libwnck
    libx11
    libxrandr
    wayland
    wayland-protocols
    wlr-protocols
  ];

  propagatedBuildInputs = [
    gtk3
  ];

  mesonFlags = [
    (lib.mesonBool "introspection" withIntrospection)
    (lib.mesonEnable "vala" withIntrospection)
  ];

  depsBuildBuild = [ pkg-config ];

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "libxfce4windowing-";
  };

  meta = {
    description = "Windowing concept abstraction library for X11 and Wayland";
    homepage = "https://gitlab.xfce.org/xfce/libxfce4windowing";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.xfce ];
  };
})
