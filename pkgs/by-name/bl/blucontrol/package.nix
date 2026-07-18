{
  lib,
  stdenv,
  haskellPackages,
  makeWrapper,
  packages ? (_: [ ]),
}:
let
  blucontrolEnv = haskellPackages.ghcWithPackages (self: [ self.blucontrol ] ++ packages self);
in
stdenv.mkDerivation {
  pname = "blucontrol-with-packages";
  version = blucontrolEnv.version;
  nativeBuildInputs = [ makeWrapper ];
  allowSubstitutes = false;

  buildCommand = ''
    makeWrapper ${blucontrolEnv}/bin/blucontrol $out/bin/blucontrol \
      --prefix PATH : ${lib.makeBinPath [ blucontrolEnv ]}
  '';

  # trivial derivation
  preferLocalBuild = true;

  meta = {
    description = "Configurable blue light filter";

    longDescription = ''
      This application is a blue light filter, with the main focus on configurability.
      Configuration is done in Haskell in the style of xmonad.
      Blucontrol makes use of monad transformers and allows monadic calculation of gamma values and recoloring. The user chooses, what will be captured in the monadic state.
    '';

    homepage = "https://github.com/jumper149/blucontrol";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ jumper149 ];
    platforms = lib.platforms.unix;
    mainProgram = "blucontrol";
  };
}
