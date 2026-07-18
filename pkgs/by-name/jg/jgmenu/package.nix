{
  lib,
  stdenv,
  fetchFromGitHub,
  gitUpdater,
  gtk3,
  librsvg,
  libxfce4util,
  libxinerama,
  libxml2,
  libxrandr,
  makeWrapper,
  menu-cache,
  pango,
  pkg-config,
  python3Packages,
  xfce4-panel,
  enableXfcePanelApplet ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jgmenu";
  version = "4.5.0";

  src = fetchFromGitHub {
    owner = "jgmenu";
    repo = "jgmenu";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-vuSpiZZYe0l5va9dHM54gaoI9x8qXH1gJORUS5489jQ=";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    python3Packages.wrapPython
  ];

  buildInputs = [
    pango
    librsvg
    libxml2
    menu-cache
    libxinerama
    libxrandr
    python3Packages.python
  ]
  ++ lib.optionals enableXfcePanelApplet [
    gtk3
    libxfce4util
    xfce4-panel
  ];

  configureFlags = [
  ]
  ++ lib.optionals enableXfcePanelApplet [
    "--with-xfce4-panel-applet"
  ];

  postFixup = ''
    wrapPythonProgramsIn "$out/lib/jgmenu"
    for f in $out/bin/jgmenu{,_run}; do
      wrapProgram $f --prefix PATH : $out/bin
    done
  '';

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Small X11 menu intended to be used with openbox and tint2";
    homepage = "https://github.com/jgmenu/jgmenu";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.romildo ];
    platforms = lib.platforms.linux;
  };
})
