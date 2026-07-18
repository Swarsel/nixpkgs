{
  lib,
  stdenv,
  bundlerEnv,
  bundlerUpdateScript,
  makeWrapper,
  ruby,
}:

stdenv.mkDerivation rec {
  pname = "lvmsync";
  version = (import ./gemset.nix).${pname}.version;
  nativeBuildInputs = [ makeWrapper ];

  installPhase =
    let
      env = bundlerEnv {
        gemfile = ./Gemfile;
        gemset = ./gemset.nix;
        lockfile = ./Gemfile.lock;
        name = "${pname}-${version}-gems";
        ruby = ruby;
      };
    in
    ''
      mkdir -p $out/bin
      makeWrapper ${env}/bin/lvmsync $out/bin/lvmsync
    '';

  dontUnpack = true;
  passthru.updateScript = bundlerUpdateScript "lvmsync";

  meta = {
    description = "Optimised synchronisation of LVM snapshots over a network";
    homepage = "https://theshed.hezmatt.org/lvmsync/";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      jluttine
      nicknovitski
    ];

    platforms = lib.platforms.all;
    mainProgram = "lvmsync";
  };

}
