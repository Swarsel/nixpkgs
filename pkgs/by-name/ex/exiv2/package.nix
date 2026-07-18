{
  lib,
  stdenv,
  fetchFromGitHub,
  brotli,
  cmake,
  doxygen,
  expat,
  gettext,
  graphviz,
  inih,
  libiconv,
  libxml2,
  libxslt,
  python3,
  removeReferencesTo,
  which,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "exiv2";
  version = "0.28.8";

  src = fetchFromGitHub {
    owner = "exiv2";
    repo = "exiv2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9Qe+lNBO24qQyKDXe7RMCqoDa61iha2QFhRpLJlCSMo=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
    "doc"
    "man"
  ];

  nativeBuildInputs = [
    cmake
    doxygen
    gettext
    graphviz
    libxslt
    removeReferencesTo
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ];

  propagatedBuildInputs = [
    brotli
    expat
    inih
    zlib
  ];

  cmakeFlags = [
    "-DEXIV2_ENABLE_NLS=ON"
    "-DEXIV2_BUILD_DOC=ON"
    "-DEXIV2_ENABLE_BMFF=ON"
  ];

  buildFlags = [
    "all"
    "doc"
  ];

  doCheck = true;

  nativeCheckInputs = [
    libxml2.bin
    python3
    which
  ];

  preCheck = ''
    patchShebangs ../test/
    mkdir ../test/tmp

    # template.exv_test (test_regression_allfiles.TestAllFiles.template.exv_test) ... ERROR
    substituteInPlace ../tests/regression_tests/test_regression_allfiles.py \
      --replace-fail '"issue_2403_poc.exv",' '"issue_2403_poc.exv", "template.exv",'
  ''
  + lib.optionalString stdenv.hostPlatform.isAarch32 ''
    # Fix tests on arm
    # https://github.com/Exiv2/exiv2/issues/933
    rm -f ../tests/bugfixes/github/test_CVE_2018_12265.py
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH''${DYLD_LIBRARY_PATH:+:}$PWD/lib
    export LC_ALL=C

    # disable tests that requires loopback networking
    substituteInPlace ../tests/bash_tests/testcases.py \
      --replace-fail "def io_test(self):" "def io_disabled(self):"
  '';

  preFixup = ''
    remove-references-to -t ${stdenv.cc.cc} $lib/lib/*.so.*.*.* $out/bin/exiv2
  '';

  disallowedReferences = [ stdenv.cc.cc ];
  # causes redefinition of _FORTIFY_SOURCE
  hardeningDisable = [ "fortify3" ];

  meta = {
    description = "Library and command-line utility to manage image metadata";
    homepage = "https://exiv2.org";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ wegank ];
    platforms = lib.platforms.all;
    mainProgram = "exiv2";
  };
})
