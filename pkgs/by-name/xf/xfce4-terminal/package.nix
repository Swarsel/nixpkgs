{
  lib,
  stdenv,
  fetchFromGitLab,
  docbook_xml_dtd_45,
  docbook_xsl,
  gitUpdater,
  glib,
  gtk-layer-shell,
  gtk3,
  libutempter,
  libx11,
  libxfce4ui,
  libxslt, # xsltproc
  meson,
  ninja,
  nixosTests,
  pcre2,
  pkg-config,
  vte,
  wrapGAppsHook3,
  xfconf,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfce4-terminal";
  version = "1.2.0";

  src = fetchFromGitLab {
    owner = "apps";
    repo = "xfce4-terminal";
    tag = "xfce4-terminal-${finalAttrs.version}";
    hash = "sha256-2zlx9pt9srMT6iKy89oKKdvh7YALOkyQTy7hRH60AOw=";
    domain = "gitlab.xfce.org";
  };

  strictDeps = true;

  nativeBuildInputs = [
    docbook_xml_dtd_45
    docbook_xsl
    glib # glib-mkenums
    libxslt # xsltproc
    meson
    ninja
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gtk3
    gtk-layer-shell
    libutempter
    libx11
    libxfce4ui
    pcre2
    vte
    xfconf
  ];

  passthru = {
    tests.test = nixosTests.terminal-emulators.xfce4-terminal;
    updateScript = gitUpdater { rev-prefix = "xfce4-terminal-"; };
  };

  meta = {
    description = "Modern terminal emulator";
    homepage = "https://gitlab.xfce.org/apps/xfce4-terminal";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "xfce4-terminal";
    teams = [ lib.teams.xfce ];
  };
})
