{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoc,
  autoconf,
  automake,
  docbook_xml_dtd_45,
  docbook_xsl,
  libarchive,
  libtool,
  libxml2,
  libxslt,
  pkg-config,
  xz,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pixz";
  version = "1.0.7";

  src = fetchFromGitHub {
    owner = "vasi";
    repo = "pixz";
    rev = "v${finalAttrs.version}";
    sha256 = "163axxs22w7pghr786hda22mnlpvmi50hzhfr9axwyyjl9n41qs2";
  };

  nativeBuildInputs = [
    pkg-config
    autoconf
    automake
  ];

  buildInputs = [
    libtool
    asciidoc
    libxslt
    libxml2
    docbook_xml_dtd_45
    docbook_xsl
    libarchive
    xz
  ];

  preConfigure = ''
    ./autogen.sh
  '';

  preBuild = ''
    echo "XML_CATALOG_FILES='$XML_CATALOG_FILES'"
  '';

  meta = {
    description = "Parallel compressor/decompressor for xz format";
    homepage = "https://github.com/vasi/pixz";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.raskin ];
    platforms = lib.platforms.unix;
    mainProgram = "pixz";
  };
})
