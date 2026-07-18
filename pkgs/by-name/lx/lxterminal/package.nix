{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  docbook_xml_dtd_412,
  docbook_xsl,
  findXMLCatalogs,
  gtk3,
  intltool,
  libxml2,
  libxslt,
  nixosTests,
  pcre2,
  pkg-config,
  vte,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lxterminal";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "lxde";
    repo = "lxterminal";
    tag = finalAttrs.version;
    hash = "sha256-oDWh0U4QWJ84hTfq1oaAmDJM+IY0eJqOUey0qBgZN5U=";
  };

  patches = [
    ./respect-xml-catalog-files-var.patch
  ];

  nativeBuildInputs = [
    autoreconfHook
    intltool
    pkg-config
    wrapGAppsHook3
    libxslt
    docbook_xml_dtd_412
    docbook_xsl
    libxml2
    findXMLCatalogs
  ];

  buildInputs = [
    gtk3
    vte
    pcre2
  ];

  configureFlags = [
    "--enable-man"
    "--enable-gtk3"
  ];

  doCheck = true;
  passthru.tests.test = nixosTests.terminal-emulators.lxterminal;

  meta = {
    description = "Standard terminal emulator of LXDE";

    longDescription = ''
      LXTerminal is the standard terminal emulator of LXDE. The terminal is a
      desktop-independent VTE-based terminal emulator for LXDE without any
      unnecessary dependencies.
    '';

    homepage = "https://www.lxde.org/";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.pbsds ];
    platforms = lib.platforms.linux;
    mainProgram = "lxterminal";
  };
})
