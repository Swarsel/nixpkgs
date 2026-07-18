{
  lib,
  stdenv,
  fetchurl,
  asciidoc,
  coreutils,
  cvs,
  diffutils,
  docbook_xml_dtd_45,
  docbook_xsl,
  findutils,
  git,
  makeWrapper,
  python3,
  rsync,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cvs-fast-export";
  version = "1.63";

  src = fetchurl {
    url = "http://www.catb.org/~esr/cvs-fast-export/cvs-fast-export-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-YZF2QebWbvn/N9pLpccudZsFHzocJp/3M0Gx9p7fQ5Y=";
  };

  postPatch = ''
    patchShebangs .
  '';

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
    asciidoc
  ];

  buildInputs = [ python3 ];

  env = lib.optionalAttrs stdenv.cc.isClang {
    NIX_CFLAGS_COMPILE = "-Wno-implicit-function-declaration";
  };

  preBuild = ''
    makeFlagsArray=(
      XML_CATALOG_FILES="${docbook_xml_dtd_45}/xml/dtd/docbook/catalog.xml ${docbook_xsl}/xml/xsl/docbook/catalog.xml"
      LIBS=""
      prefix="$out"
    )
  '';

  postInstall = ''
    wrapProgram $out/bin/cvssync --prefix PATH : ${lib.makeBinPath [ rsync ]}
    wrapProgram $out/bin/cvsconvert --prefix PATH : $out/bin:${
      lib.makeBinPath [
        coreutils
        cvs
        diffutils
        findutils
        git
      ]
    }
  '';

  meta = {
    description = "Export an RCS or CVS history as a fast-import stream";
    homepage = "http://www.catb.org/esr/cvs-fast-export/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ dfoxfranke ];
    platforms = lib.platforms.unix;
  };
})
