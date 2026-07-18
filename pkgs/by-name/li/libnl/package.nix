{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoc,
  autoreconfHook,
  bison,
  doxygen,
  file,
  flex,
  graphviz,
  mscgen,
  pkg-config,
  python3Packages,
  sourceHighlight,
  enableDocs ? false,
  python ? null,
  pythonSupport ? false,
  swig ? null,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libnl";
  version = "3.12.0";

  src = fetchFromGitHub {
    owner = "thom311";
    repo = "libnl";
    rev = "libnl${lib.replaceStrings [ "." ] [ "_" ] finalAttrs.version}";
    hash = "sha256-K77WamOf+/3PNXe/hI+OYg0EBgBqvDfNDamXYXcK7P8=";
  };

  outputs = [
    "bin"
    "dev"
    "out"
    "man"
  ]
  ++ lib.optional pythonSupport "py"
  ++ lib.optional enableDocs "doc";

  nativeBuildInputs = [
    autoreconfHook
    bison
    flex
    pkg-config
    file
  ]
  ++ lib.optionals pythonSupport [
    swig
  ]
  ++ lib.optionals enableDocs [
    doxygen
    graphviz
    mscgen
    asciidoc
    sourceHighlight
    python3Packages.pygments
  ];

  configureFlags = [ (lib.enableFeature enableDocs "doc") ];

  postBuild = lib.optionalString pythonSupport ''
    cd python
    ${python.pythonOnBuildForHost.interpreter} setup.py install --prefix=../pythonlib
    cd -
  '';

  postInstall = lib.optionalString enableDocs ''
    patchShebangs doc
    # See tools/build_release.sh
    make -C doc
    make -C doc gendoc
    make -C doc dist
    mkdir -p $doc/share/doc/libnl
    cp doc/libnl-doc-${finalAttrs.version}.tar.gz $doc/share/doc/libnl
  '';

  postFixup = lib.optionalString pythonSupport ''
    mv "pythonlib/" "$py"
  '';

  enableParallelBuilding = true;

  passthru = {
    inherit pythonSupport;
  };

  meta = {
    description = "Linux Netlink interface library suite";
    homepage = "http://www.infradead.org/~tgr/libnl/";
    license = lib.licenses.lgpl21;
    maintainers = with lib.maintainers; [ fpletz ];
    platforms = lib.platforms.linux;
    identifiers.cpeParts = lib.meta.cpeFullVersionWithVendor "libnl_project" finalAttrs.version;
  };
})
