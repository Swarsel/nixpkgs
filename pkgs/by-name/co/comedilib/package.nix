{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  bison,
  docbook_xml_dtd_44,
  docbook_xsl,
  flex,
  perl,
  python3,
  swig,
  udevCheckHook,
  xmlto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "comedilib";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "Linux-Comedi";
    repo = "comedilib";
    tag = "r${lib.replaceStrings [ "." ] [ "_" ] finalAttrs.version}";
    hash = "sha256-3Hl6CHRvSzpNXXT6Z8RRbKKM/DS46+eORF9uYXgT2k0=";
  };

  outputs = [
    "out"
    "dev"
    "man"
    "doc"
  ];

  nativeBuildInputs = [
    autoreconfHook
    flex
    bison
    swig
    xmlto
    docbook_xml_dtd_44
    docbook_xsl
    python3
    perl
    udevCheckHook
  ];

  configureFlags = [
    "--with-udev-hotplug=${placeholder "out"}/lib"
    "--sysconfdir=${placeholder "out"}/etc"
  ];

  preConfigure = ''
    patchShebangs --build doc/mkref doc/mkdr perl/Comedi.pm
  '';

  doInstallCheck = true;

  meta = {
    description = "Linux Control and Measurement Device Interface Library";
    homepage = "https://github.com/Linux-Comedi/comedilib";
    license = lib.licenses.lgpl21;
    maintainers = with lib.maintainers; [ doronbehar ];
    platforms = lib.platforms.linux;
  };
})
