{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  docbook_xml_dtd_412,
  docbook_xsl,
  gtk2,
  gtk3,
  intltool,
  libx11,
  libxml2,
  libxslt,
  pkg-config,
  xrandr,
  withGtk3 ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lxrandr";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "lxde";
    repo = "lxrandr";
    tag = finalAttrs.version;
    hash = "sha256-EGUnvV1FqQUJkjGwxgVecXOohAu8Qa8Prgk6xZfJBe4=";
  };

  patches = [ ./respect-xml-catalog-files-var.patch ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    intltool
    libxslt
    libxml2
    docbook_xml_dtd_412
    docbook_xsl
  ];

  buildInputs = [
    libx11
    xrandr
    (if withGtk3 then gtk3 else gtk2)
  ];

  configureFlags = [
    "--enable-man"
  ]
  ++ lib.optional withGtk3 "--enable-gtk3";

  meta = {
    description = "Standard screen manager of LXDE";
    homepage = "https://lxde.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ rawkode ];
    platforms = lib.platforms.linux;
    mainProgram = "lxrandr";
  };
})
