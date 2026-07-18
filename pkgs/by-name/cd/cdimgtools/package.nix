{
  lib,
  stdenv,
  asciidoc,
  autoreconfHook,
  docbook_xml_dtd_45,
  docbook_xsl,
  fetchFromRepoOrCz,
  libdvdcss,
  libdvdread,
  makeWrapper,
  perl,
  perlPackages,
  sourceHighlight,
  xmlto,
}:

stdenv.mkDerivation {
  pname = "cdimgtools";
  version = "0.3";

  src = fetchFromRepoOrCz {
    repo = "cdimgtools";
    rev = "version/0.3";
    hash = "sha256-HFlXGmi6YcYP+ZAdu79lJHLBmtMEhW17gs4I2ekbr8M=";
  };

  outputs = [
    "out"
    "doc"
  ];

  patches = [
    ./nrgtool_fix_my.patch
    ./removed_dvdcss_interface_2.patch
  ];

  nativeBuildInputs = [
    autoreconfHook
    makeWrapper
    asciidoc
    perlPackages.PodPerldoc
    xmlto
    sourceHighlight
    docbook_xsl
    docbook_xml_dtd_45
  ];

  buildInputs = [
    perl
    perlPackages.StringEscape
    perlPackages.DataHexdumper
    libdvdcss
    libdvdread
  ];

  postFixup = ''
    for cmd in raw96cdconv nrgtool; do
      wrapProgram "$out/bin/$cmd" --prefix PERL5LIB : "$PERL5LIB"
    done
  '';

  installTargets = [
    "install"
    "install-doc"
  ];

  meta = {
    description = "Tools to inspect and manipulate CD/DVD optical disc images";
    homepage = "https://repo.or.cz/cdimgtools.git/blob_plain/refs/heads/release:/README.html";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ hhm ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
