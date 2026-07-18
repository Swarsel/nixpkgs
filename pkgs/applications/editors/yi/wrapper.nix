# To use this for hacking of your Yi config file, drop into a shell
# with env attribute.
{
  lib,
  stdenv,
  haskellPackages,
  makeWrapper,
  extraPackages ? (s: [ ]),
}:
let
  yiEnv = haskellPackages.ghcWithPackages (self: [ self.yi ] ++ extraPackages self);
in
stdenv.mkDerivation {
  inherit (haskellPackages.yi) meta version;
  pname = "yi-custom";
  nativeBuildInputs = [ makeWrapper ];

  buildCommand = ''
    mkdir -p $out/bin
    makeWrapper ${haskellPackages.yi}/bin/yi $out/bin/yi \
      --set NIX_GHC ${yiEnv}/bin/ghc
  '';

  dontUnpack = true;
  # For hacking purposes
  passthru.env = yiEnv;
}
