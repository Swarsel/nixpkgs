{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  boost,
  cppunit,
  curl,
  docbook_xml_dtd_43,
  libxml2,
  pkg-config,
  xmlto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libcmis";
  version = "0.6.3";

  src = fetchFromGitHub {
    owner = "tdf";
    repo = "libcmis";
    tag = "v${finalAttrs.version}";
    hash = "sha256-chLY9tbhVPIiP+twsNM2SM7Bqyau/evQGKHfjlac6ys=";
  };

  postPatch = ''
    substituteInPlace doc/cmis-client.xml.in \
      --replace-fail "http://www.oasis-open.org/docbook/xml/4.3/docbookx.dtd" \
                     "${docbook_xml_dtd_43}/xml/dtd/docbook/docbookx.dtd"
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    xmlto
  ];

  buildInputs = [
    boost
    libxml2
    curl
    cppunit
  ];

  configureFlags = [
    "--disable-werror"
    "--with-boost=${boost.dev}"
  ];

  doCheck = true;
  enableParallelBuilding = true;

  meta = {
    description = "C++ client library for the CMIS interface";
    homepage = "https://github.com/tdf/libcmis";
    changelog = "https://github.com/tdf/libcmis/blob/${finalAttrs.src.tag}/NEWS";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.unix;
    mainProgram = "cmis-client";
  };
})
