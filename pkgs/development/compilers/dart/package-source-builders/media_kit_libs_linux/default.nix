{
  lib,
  stdenv,
  mimalloc,
}:

{ src, version, ... }:

stdenv.mkDerivation {
  inherit version src;
  inherit (src) passthru;
  pname = "media_kit_libs_linux";

  # Remove mimalloc download
  # Direct link for the original CMakeLists.txt: https://raw.githubusercontent.com/media-kit/media-kit/main/libs/linux/media_kit_libs_linux/linux/CMakeLists.txt
  postPatch = ''
    pushd ${src.passthru.packageRoot}
  ''
  + lib.optionalString (lib.versionAtLeast version "1.2.1") ''
    sed -i '/if(MIMALLOC_USE_STATIC_LIBS)/,/unset(MIMALLOC_USE_STATIC_LIBS CACHE)/c\set(MIMALLOC_LIB "${lib.getLib mimalloc}/lib/mimalloc.o" CACHE INTERNAL "")' linux/CMakeLists.txt
  ''
  + lib.optionalString (lib.versionOlder version "1.2.1") ''
    sed -i '/# --\+/,/# --\+/c\set(MIMALLOC_LIB "${lib.getLib mimalloc}/lib/mimalloc.o")' linux/CMakeLists.txt
  ''
  + ''
    popd
  '';

  installPhase = ''
    runHook preInstall

    cp -r . $out

    runHook postInstall
  '';

  dontBuild = true;
}
