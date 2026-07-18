{
  lib,
  stdenv,
  openssl,
  writeScript,
}:

{ src, version, ... }:

stdenv.mkDerivation rec {
  inherit version src;
  inherit (src) passthru;
  pname = "matrix";

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    ln -s '${src}'/* "$out"

    runHook postInstall
  '';

  setupHook = writeScript "${pname}-setup-hook" ''
    matrixFixupHook() {
      runtimeDependencies+=('${lib.getLib openssl}')
    }

    preFixupHooks+=(matrixFixupHook)
  '';
}
