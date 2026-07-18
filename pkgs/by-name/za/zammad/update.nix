{
  lib,
  bundix,
  common-updater-scripts,
  jq,
  makeWrapper,
  nix-prefetch-github,
  stdenvNoCC,
  xidel,
  yarn,
}:

stdenvNoCC.mkDerivation rec {
  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    bundix
    common-updater-scripts
    xidel
    jq
    nix-prefetch-github
    yarn
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp ${./update.sh} $out/bin/update.sh
    patchShebangs $out/bin/update.sh
    wrapProgram $out/bin/update.sh --prefix PATH : ${lib.makeBinPath buildInputs}
  '';

  dontUnpack = true;
  name = "zammad-update-script";

  meta = {
    description = "Utility to generate Nix expressions for Zammad's dependencies";
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
}
