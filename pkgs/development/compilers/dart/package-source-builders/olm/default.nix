{
  lib,
  stdenv,
  olm,
  writeScript,
}:

{ src, version, ... }:

stdenv.mkDerivation rec {
  inherit version src;
  inherit (src) passthru;
  pname = "olm";

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    ln -s '${src}'/* "$out"

    runHook postInstall
  '';

  setupHook = writeScript "${pname}-setup-hook" ''
    olmFixupHook() {
      runtimeDependencies+=('${lib.getLib olm}')
    }

    preFixupHooks+=(olmFixupHook)
  '';
}
