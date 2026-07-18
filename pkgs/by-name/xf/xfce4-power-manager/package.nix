{
  lib,
  stdenv,
  fetchFromGitLab,
  gettext,
  gitUpdater,
  gtk3,
  libnotify,
  libxfce4ui,
  libxfce4util,
  pkg-config,
  polkit,
  upower,
  wayland-protocols,
  wayland-scanner,
  wlr-protocols,
  wrapGAppsHook3,
  xfce4-dev-tools,
  xfce4-panel,
  xfconf,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfce4-power-manager";
  version = "4.20.0";

  src = fetchFromGitLab {
    owner = "xfce";
    repo = "xfce4-power-manager";
    tag = "xfce4-power-manager-${finalAttrs.version}";
    hash = "sha256-qKUdrr+giLzNemhT3EQsOKTSiIx50NakmK14Ak7ZOCE=";
    domain = "gitlab.xfce.org";
  };

  # using /run/current-system/sw/bin instead of nix store path prevents polkit permission errors on
  # rebuild.  See https://github.com/NixOS/nixpkgs/issues/77485
  postPatch = ''
    substituteInPlace common/xfpm-brightness-polkit.c --replace-fail "SBINDIR" "\"/run/current-system/sw/bin\""
    substituteInPlace src/xfpm-suspend.c --replace-fail "SBINDIR" "\"/run/current-system/sw/bin\""
  '';

  nativeBuildInputs = [
    gettext
    pkg-config
    wayland-scanner
    xfce4-dev-tools
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    libnotify
    libxfce4ui
    libxfce4util
    polkit
    upower
    wayland-protocols
    wlr-protocols
    xfconf
    xfce4-panel
  ];

  configureFlags = [
    "--enable-maintainer-mode"
    "--sbindir=\${out}/bin"
  ];

  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "xfce4-power-manager-";
  };

  meta = {
    description = "Power manager for the Xfce Desktop Environment";
    homepage = "https://gitlab.xfce.org/xfce/xfce4-power-manager";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "xfce4-power-manager";
    teams = [ lib.teams.xfce ];
  };
})
