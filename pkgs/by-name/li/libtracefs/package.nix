{
  lib,
  stdenv,
  asciidoc,
  bison,
  docbook_xml_dtd_45,
  docbook_xsl,
  fetchzip,
  flex,
  gitUpdater,
  libtraceevent,
  meson,
  ninja,
  pkg-config,
  sourceHighlight,
  xmlto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libtracefs";
  version = "1.8.3";

  src = fetchzip {
    url = "https://git.kernel.org/pub/scm/libs/libtrace/libtracefs.git/snapshot/libtracefs-libtracefs-${finalAttrs.version}.tar.gz";
    hash = "sha256-uN4alsOmj7IFUL2IJSHbgBiztv2Sq0+MktQiRByvhK0=";
  };

  outputs = [
    "out"
    "dev"
    "devman"
    "doc"
  ];

  postPatch = ''
    chmod +x samples/extract-example.sh
    patchShebangs --build check-manpages.sh samples/extract-example.sh Documentation/install-docs.sh.in
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    asciidoc
    xmlto
    docbook_xml_dtd_45
    docbook_xsl
    sourceHighlight
    flex
    bison
  ];

  buildInputs = [ libtraceevent ];
  doCheck = false; # needs root

  ninjaFlags = [
    "all"
    "docs"
  ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "libtracefs-";
    # No nicer place to find latest release.
    url = "https://git.kernel.org/pub/scm/libs/libtrace/libtracefs.git";
  };

  meta = {
    description = "Linux kernel trace file system library";
    homepage = "https://git.kernel.org/pub/scm/libs/libtrace/libtracefs.git/";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ wentasah ];
    platforms = lib.platforms.linux;
    mainProgram = "sqlhist";
  };
})
