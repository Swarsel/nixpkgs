{
  lib,
  stdenv,
  asciidoc,
  docbook_xml_dtd_45,
  docbook_xsl,
  fetchzip,
  gitUpdater,
  libtraceevent,
  libtracefs,
  libxslt,
  pkg-config,
  sourceHighlight,
  xmlto,
  zstd,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "trace-cmd";
  version = "3.4";

  src = fetchzip {
    url = "https://git.kernel.org/pub/scm/utils/trace-cmd/trace-cmd.git/snapshot/trace-cmd-v${finalAttrs.version}.tar.gz";
    hash = "sha256-7IMInvVLIjGcHZvnSzhcne+4ieFa85ep7KMn2Oy9pF8=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
    "man"
    "devman"
  ];

  # Don't build and install html documentation
  postPatch = ''
    sed -i -e '/^all:/ s/html//' -e '/^install:/ s/install-html//' \
       Documentation{,/trace-cmd,/libtracecmd}/Makefile
    patchShebangs check-manpages.sh
  '';

  nativeBuildInputs = [
    asciidoc
    libxslt
    pkg-config
    xmlto
    docbook_xsl
    docbook_xml_dtd_45
    sourceHighlight
  ];

  buildInputs = [
    libtraceevent
    libtracefs
    zstd
  ];

  makeFlags = [
    # The following values appear in the generated .pc file
    "prefix=${placeholder "lib"}"
  ];

  env.MANPAGE_DOCBOOK_XSL = "${docbook_xsl}/xml/xsl/docbook/manpages/docbook.xsl";

  # We do not mention targets (like "doc") explicitly in makeFlags
  # because the Makefile would not print warnings about too old
  # libraries (see "warning:" in the Makefile)
  postBuild = ''
    make libs doc -j$NIX_BUILD_CORES
  '';

  dontConfigure = true;
  enableParallelBuilding = true;

  installFlags = [
    "LDCONFIG=false"
    "bindir=${placeholder "out"}/bin"
    "mandir=${placeholder "man"}/share/man"
    "libdir=${placeholder "lib"}/lib"
    "pkgconfig_dir=${placeholder "dev"}/lib/pkgconfig"
    "includedir=${placeholder "dev"}/include"
    "completion_dir=${placeholder "out"}/share/bash-completion/completions"
  ];

  installTargets = [
    "install_cmd"
    "install_libs"
    "install_doc"
  ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "trace-cmd-v";
    # No nicer place to find latest release.
    url = "https://git.kernel.org/pub/scm/utils/trace-cmd/trace-cmd.git";
  };

  meta = {
    description = "User-space tools for the Linux kernel ftrace subsystem";
    homepage = "https://www.trace-cmd.org/";

    license = with lib.licenses; [
      lgpl21Only
      gpl2Only
    ];

    maintainers = with lib.maintainers; [
      thoughtpolice
      basvandijk
      wentasah
    ];

    platforms = lib.platforms.linux;
    mainProgram = "trace-cmd";
  };
})
