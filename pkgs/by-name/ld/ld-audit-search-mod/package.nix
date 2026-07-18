{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  spdlog,
  yaml-cpp,
  storeDir ? builtins.storeDir,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ld-audit-search-mod";
  version = "0-unstable-2025-06-19";

  src = fetchFromGitHub {
    owner = "DDoSolitary";
    repo = "ld-audit-search-mod";
    rev = "261f475f154d0f1f0766d6756af9c714eeeb14ea";
    hash = "sha256-c6ub+m4ihIE3gh6yHtLfJIVqm12C46wThrBCqp8SOLE=";
    sparseCheckout = [ "src" ];
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    spdlog
    yaml-cpp
  ];

  cmakeFlags = [
    (lib.cmakeFeature "NIX_RTLD_NAME" (baseNameOf stdenv.cc.bintools.dynamicLinker))
    (lib.cmakeFeature "NIX_STORE_DIR" storeDir)
  ];

  sourceRoot = "${finalAttrs.src.name}/src";

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Audit module that modifies ld.so library search behavior";
    license = lib.licenses.mit;

    maintainers = [
      lib.maintainers.atry
      lib.maintainers.DDoSolitary
    ];

    platforms = lib.platforms.linux;
  };
})
