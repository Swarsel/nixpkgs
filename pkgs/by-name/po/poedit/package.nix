{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoc,
  autoconf,
  automake,
  boost,
  gettext,
  gtk3,
  gtkspell3,
  hicolor-icon-theme,
  icu,
  libtool,
  libxslt,
  lucenepp,
  nix-update-script,
  nlohmann_json,
  pkg-config,
  pugixml,
  wrapGAppsHook3,
  wxwidgets_3_2,
  xmlto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "poedit";
  version = "3.9.1";

  src = fetchFromGitHub {
    owner = "vslavik";
    repo = "poedit";
    rev = "v${finalAttrs.version}-oss";
    hash = "sha256-WLXIPvAMJd8zkx1r4XMzjl+NZDpB6WHVSksx6oz1AiA=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    asciidoc
    wrapGAppsHook3
    libxslt
    xmlto
    boost
    libtool
    pkg-config
  ];

  buildInputs = [
    lucenepp
    nlohmann_json
    wxwidgets_3_2
    icu
    pugixml
    gtk3
    gtkspell3
    hicolor-icon-theme
  ];

  propagatedBuildInputs = [ gettext ];

  configureFlags = [
    "--without-cld2"
    "--without-cpprest"
    "--with-boost-libdir=${boost.out}/lib"
    "CPPFLAGS=-I${nlohmann_json}/include/nlohmann/"
    "LDFLAGS=-llucene++"
  ];

  preConfigure = "
    patchShebangs bootstrap
    ./bootstrap
  ";

  preFixup = ''
    gappsWrapperArgs+=(--prefix PATH : "${lib.makeBinPath [ gettext ]}")
  '';

  enableParallelBuilding = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "(.*)-oss"
    ];
  };

  meta = {
    description = "Cross-platform gettext catalogs (.po files) editor";
    homepage = "https://www.poedit.net/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dasj19 ];
    platforms = lib.platforms.unix;
    mainProgram = "poedit";
    # configure: error: GTK+ build of wxWidgets is required
    broken = stdenv.hostPlatform.isDarwin;
  };
})
