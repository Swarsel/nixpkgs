{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  cmake,
  fetchpatch,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lerc";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "esri";
    repo = "lerc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+X30DQuq2oT/sTe8usUaNK1V+UTNvXJW7IAJVIr8m78=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = lib.optionals stdenv.hostPlatform.isFreeBSD [
    (fetchpatch {
      extraPrefix = "";
      hash = "sha256-agvGqgIsKS8v43UZdTVxDRDGbZdj2+AzKoQONvQumB4=";
      url = "https://raw.githubusercontent.com/freebsd/freebsd-ports/ee9e39ceb1af729ac33854b5f3de652cb5ce0eca/graphics/lerc/files/patch-_assert";
    })
  ];

  nativeBuildInputs = [
    cmake
  ];

  # Required to get the freebsd-ports patch to apply.
  # There seem to be inconsistent line endings in this project - just converting the patch doesn't work
  prePatch = lib.optionalString stdenv.hostPlatform.isFreeBSD ''
    ${buildPackages.dos2unix}/bin/dos2unix src/LercLib/fpl_EsriHuffman.cpp src/LercLib/fpl_Lerc2Ext.cpp
  '';

  passthru.tests.pkg-config = testers.hasPkgConfigModules {
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "C++ library for Limited Error Raster Compression";
    homepage = "https://github.com/esri/lerc";
    changelog = "https://github.com/Esri/lerc/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
    pkgConfigModules = [ "Lerc" ];
  };
})
