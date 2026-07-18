{
  lib,
  stdenv,
  cairo,
  fribidi,
  writeScript,
}:

{ src, version, ... }:

stdenv.mkDerivation rec {
  inherit version src;
  inherit (src) passthru;
  pname = "handy-window";

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    ln -s '${src}'/* "$out"

    runHook postInstall
  '';

  setupHook = writeScript "${pname}-setup-hook" ''
    handyWindowConfigureHook() {
      export CFLAGS="$CFLAGS -isystem ${lib.getDev fribidi}/include/fribidi -isystem ${lib.getDev cairo}/include"
    }

    postConfigureHooks+=(handyWindowConfigureHook)
  '';
}
