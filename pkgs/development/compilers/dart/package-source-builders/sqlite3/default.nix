{
  lib,
  stdenv,
  sqlite,
  writeScript,
}:

{ src, version, ... }:

stdenv.mkDerivation (finalAttrs: {
  inherit version src;
  inherit (src) passthru;
  pname = "sqlite3";

  postPatch = lib.optionalString (lib.versionAtLeast version "3.2.0") ''
    substituteInPlace lib/src/hook/description.dart \
      --replace-fail "return PrecompiledFromGithubAssets(LibraryType.sqlite3);" "return LookupSystem('sqlite3');"
  '';

  installPhase = ''
    runHook preInstall

    cp --recursive . "$out"

    runHook postInstall
  '';

  setupHook = writeScript "${finalAttrs.pname}-setup-hook" ''
    sqliteFixupHook() {
      runtimeDependencies+=('${lib.getLib sqlite}')
    }

    preFixupHooks+=(sqliteFixupHook)
  '';
})
