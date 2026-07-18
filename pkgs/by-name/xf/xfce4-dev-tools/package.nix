{
  lib,
  stdenv,
  fetchFromGitLab,
  autoconf,
  automake,
  autoreconfHook,
  docbook_xsl,
  gitUpdater,
  glib,
  gtk-doc,
  intltool,
  libtool,
  libxslt,
  meson,
  pkg-config,
  python3,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfce4-dev-tools";
  version = "4.20.0";

  src = fetchFromGitLab {
    owner = "xfce";
    repo = "xfce4-dev-tools";
    rev = "xfce4-dev-tools-${finalAttrs.version}";
    hash = "sha256-eUfNa/9ksLCKtVwBRtHaVl7Yl95tukUaDdoLNfeR+Ew=";
    domain = "gitlab.xfce.org";
  };

  nativeBuildInputs = [
    autoreconfHook
    docbook_xsl
    libxslt # for xsltproc
    # x-d-t itself is not a meson project, but the xfce-do-release script wants
    # `meson rewrite kwargs`, thus this is checked by `AC_CHECK_PROGS`.
    meson
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    python3 # for xdt-gen-visibility
  ];

  propagatedBuildInputs = [
    autoconf
    automake
    glib
    gtk-doc
    intltool
    libtool
  ];

  configureFlags = [ "--enable-maintainer-mode" ];
  dontUseMesonConfigure = true;
  enableParallelBuilding = true;
  setupHook = ./setup-hook.sh;

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "xfce4-dev-tools-";
  };

  meta = {
    description = "Autoconf macros and scripts to augment app build systems";
    homepage = "https://gitlab.xfce.org/xfce/xfce4-dev-tools";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.xfce ];
  };
})
