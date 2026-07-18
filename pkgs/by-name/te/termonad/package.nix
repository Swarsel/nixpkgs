{
  stdenv,
  haskellPackages,
  makeWrapper,
  nixosTests,
  packages ? (pkgSet: [ ]),
}:

let
  termonadEnv = haskellPackages.ghcWithPackages (self: [ self.termonad ] ++ packages self);
in
stdenv.mkDerivation {
  inherit (haskellPackages.termonad) version;
  pname = "termonad-with-packages";
  nativeBuildInputs = [ makeWrapper ];
  allowSubstitutes = false;

  buildCommand = ''
    mkdir -p $out/bin $out/share
    makeWrapper ${termonadEnv}/bin/termonad $out/bin/termonad \
      --set NIX_GHC "${termonadEnv}/bin/ghc"
  '';

  # trivial derivation
  preferLocalBuild = true;
  passthru.tests.test = nixosTests.terminal-emulators.termonad;

  meta = haskellPackages.termonad.meta // {
    mainProgram = "termonad";
  };
}
