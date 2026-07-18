{
  lib,
  stdenv,
  fetchFromGitLab,
  gitUpdater,
  glib,
  gobject-introspection,
  gtk3,
  meson,
  ninja,
  pkg-config,
  python3,
  shared-mime-info,
  wrapGAppsHook3,
  xdg-utils,
  xfconf,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "catfish";
  version = "4.20.1";

  src = fetchFromGitLab {
    owner = "apps";
    repo = "catfish";
    rev = "catfish-${finalAttrs.version}";
    hash = "sha256-mTAunc1GJLkSu+3oWD5+2sCQemWdVsUURlP09UkbVyw=";
    domain = "gitlab.xfce.org";
  };

  postPatch = ''
    substituteInPlace catfish/CatfishWindow.py \
      --replace-fail "/usr/share/mime" "${shared-mime-info}/share/mime"
  '';

  nativeBuildInputs = [
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gtk3
    (python3.withPackages (p: [
      p.dbus-python
      p.pygobject3
      p.pexpect
    ]))
    xfconf
  ];

  preFixup = ''
    # For xdg-mime and xdg-open.
    gappsWrapperArgs+=(--prefix PATH : "${lib.makeBinPath [ xdg-utils ]}")
  '';

  passthru.updateScript = gitUpdater { rev-prefix = "catfish-"; };

  meta = {
    description = "Handy file search tool";

    longDescription = ''
      Catfish is a handy file searching tool. The interface is
      intentionally lightweight and simple, using only GTK 3.
      You can configure it to your needs by using several command line
      options.
    '';

    homepage = "https://docs.xfce.org/apps/catfish/start";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "catfish";
    teams = [ lib.teams.xfce ];
  };
})
