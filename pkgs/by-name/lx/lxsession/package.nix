{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  docbook_xml_dtd_412,
  docbook_xsl,
  gtk2-x11,
  intltool,
  libx11,
  libxml2,
  libxslt,
  pkg-config,
  polkit,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lxsession";
  version = "0.5.6";

  src = fetchFromGitHub {
    owner = "lxde";
    repo = "lxsession";
    tag = finalAttrs.version;
    hash = "sha256-3RnRF4oMCtZbIraHVqEPnkviAkELq7uYqyHY0uCf/lU=";
  };

  patches = [ ./repect-xml-catalog-file-var.patch ];

  postPatch = ''
    mkdir -p m4
  '';

  nativeBuildInputs = [
    autoreconfHook
    intltool
    libxml2
    libxslt
    pkg-config
    wrapGAppsHook3
    docbook_xml_dtd_412
    docbook_xsl
  ];

  buildInputs = [
    gtk2-x11
    libx11
    polkit
    vala
  ];

  configureFlags = [
    "--enable-man"
    "--disable-buildin-clipboard"
    "--disable-buildin-polkit"
  ];

  meta = {
    description = "Classic LXDE session manager";
    homepage = "https://wiki.lxde.org/en/LXSession";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    mainProgram = "lxsession";
  };
})
