{
  lib,
  stdenv,
  fetchFromGitLab,
  buildPackages,
  docbook_xsl,
  gdk-pixbuf,
  gettext,
  gitUpdater,
  gobject-introspection,
  gtk3,
  libexif,
  libgudev,
  libnotify,
  libx11,
  libxfce4ui,
  libxfce4util,
  libxslt,
  pcre2,
  pkg-config,
  wrapGAppsHook3,
  xfce4-dev-tools,
  xfce4-exo,
  xfce4-panel,
  xfconf,
  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "thunar";
  version = "4.20.8";

  src = fetchFromGitLab {
    owner = "xfce";
    repo = "thunar";
    tag = "thunar-${finalAttrs.version}";
    hash = "sha256-gcNo9HNBY5NGhJ8N8DBTXYb5gsNAXrItvWuo3XdSBRg=";
    domain = "gitlab.xfce.org";
  };

  outputs = [
    "out"
    "dev"
  ];

  # the desktop file … is in an insecure location»
  # which pops up when invoking desktop files that are
  # symlinks to the /nix/store
  #
  # this error was added by this commit:
  # https://github.com/xfce-mirror/thunar/commit/1ec8ff89ec5a3314fcd6a57f1475654ddecc9875
  postPatch = ''
    sed -i -e 's|thunar_dialogs_show_insecure_program (parent, _(".*"), file, exec)|1|' thunar/thunar-file.c
  '';

  nativeBuildInputs = [
    docbook_xsl
    gettext
    libxslt
    pkg-config
    xfce4-dev-tools
    wrapGAppsHook3
  ]
  ++ lib.optionals withIntrospection [
    gobject-introspection
  ];

  buildInputs = [
    xfce4-exo
    gdk-pixbuf
    gtk3
    libx11
    libexif # image properties page
    libgudev
    libnotify
    libxfce4ui
    libxfce4util
    pcre2 # search & replace renamer
    xfce4-panel # trash panel applet plugin
    xfconf
  ];

  configureFlags = [
    "--enable-maintainer-mode"
    "--with-custom-thunarx-dirs-enabled"
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      # https://github.com/NixOS/nixpkgs/issues/329688
      --prefix PATH : ${lib.makeBinPath [ xfce4-exo ]}
    )
  '';

  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "thunar-";
  };

  meta = {
    description = "Xfce file manager";
    homepage = "https://gitlab.xfce.org/xfce/thunar";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "thunar";
    teams = [ lib.teams.xfce ];
  };
})
