{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ctestCheckHook,
  # for passthru.tests
  cups-filters,
  libjpeg,
  pdfmixtool,
  perl,
  python3,
  testers,
  versionCheckHook,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qpdf";
  version = "12.3.2";

  src = fetchFromGitHub {
    owner = "qpdf";
    repo = "qpdf";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qHc9v3VYrxbOhpsPbaaO7foumI2AdeFN9Z9Zbs4XtKg=";
  };

  outputs = [
    "bin"
    "doc"
    "lib"
    "man"
    "out"
  ];

  nativeBuildInputs = [
    cmake
    perl
  ];

  buildInputs = [
    zlib
    libjpeg
  ];

  cmakeFlags = [
    (lib.cmakeBool "SHOW_FAILED_TEST_OUTPUT" true)
  ];

  preConfigure = ''
    patchShebangs qtest/bin/qtest-driver
    patchShebangs run-qtest
    # qtest needs to know where the source code is
    substituteInPlace CMakeLists.txt --replace "run-qtest" "run-qtest --top $src --code $src --bin $out"
  '';

  doCheck = true;
  nativeCheckInputs = [ ctestCheckHook ];
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  # Cursed system‐dependent(?!) failure with libc++ because another
  # test in the same process sets the global locale; skip for now.
  #
  # See:
  # * <https://github.com/llvm/llvm-project/issues/39399>
  # * <https://github.com/llvm/llvm-project/issues/123309>
  ${if stdenv.cc.libcxx != null then "patches" else null} = [
    ./disable-timestamp-test.patch
  ];

  passthru.tests = {
    inherit (python3.pkgs) pikepdf;

    inherit
      cups-filters
      pdfmixtool
      ;

    pkg-config = testers.hasPkgConfigModules { package = finalAttrs.finalPackage; };
  };

  meta = {
    description = "C++ library and set of programs that inspect and manipulate the structure of PDF files";
    homepage = "https://qpdf.sourceforge.io/";
    changelog = "https://qpdf.readthedocs.io/en/${lib.versions.majorMinor finalAttrs.version}/release-notes.html";
    license = lib.licenses.asl20; # as of 7.0.0, people may stay at artistic2
    maintainers = [ lib.maintainers.dotlambda ];
    platforms = lib.platforms.all;
    mainProgram = "qpdf";
    pkgConfigModules = [ "libqpdf" ];
  };
})
