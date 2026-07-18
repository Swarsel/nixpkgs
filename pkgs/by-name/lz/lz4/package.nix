{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  testers,
  valgrind,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lz4";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "lz4";
    repo = "lz4";
    rev = "v${finalAttrs.version}";
    hash = "sha256-/dG1n59SKBaEBg72pAWltAtVmJ2cXxlFFhP+klrkTos=";
  };

  outputs = [
    "dev"
    "lib"
    "man"
    "out"
  ];

  patches = [
    (fetchpatch {
      hash = "sha256-qOvK0A3MGX14WdhThV7m4G6s+ZMP6eA/07A2BY5nesY=";
      name = "CVE-2025-62813.patch";
      url = "https://github.com/lz4/lz4/commit/f64efec011c058bd70348576438abac222fe6c82.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = lib.optionals finalAttrs.finalPackage.doCheck [
    valgrind
  ];

  doCheck = false; # tests take a very long time
  checkTarget = "test";
  cmakeBuildDir = "build-dist";
  cmakeDir = "../build/cmake";

  passthru.tests = {
    version = testers.testVersion {
      version = "v${finalAttrs.version}";
      package = finalAttrs.finalPackage;
    };

    pkg-config = testers.hasPkgConfigModules {
      moduleNames = [ "liblz4" ];
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "Extremely fast compression algorithm";

    longDescription = ''
      Very fast lossless compression algorithm, providing compression speed
      at 400 MB/s per core, with near-linear scalability for multi-threaded
      applications. It also features an extremely fast decoder, with speed in
      multiple GB/s per core, typically reaching RAM speed limits on
      multi-core systems.
    '';

    homepage = "https://lz4.github.io/lz4/";

    license = with lib.licenses; [
      bsd2
      gpl2Plus
    ];

    maintainers = [ lib.maintainers.tobim ];
    platforms = lib.platforms.all;
    mainProgram = "lz4";
    identifiers.cpeParts = lib.meta.cpeFullVersionWithVendor "lz4_project" finalAttrs.version;
  };
})
