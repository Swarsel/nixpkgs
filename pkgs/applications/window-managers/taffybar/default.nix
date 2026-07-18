{
  stdenv,
  ghcWithPackages,
  makeWrapper,
  taffybar,
  packages ? (x: [ ]),
}:

let
  taffybarEnv = ghcWithPackages (
    self:
    [
      self.taffybar
    ]
    ++ packages self
  );
in
stdenv.mkDerivation {
  inherit (taffybar) version;
  inherit (taffybar) meta;
  pname = "taffybar-with-packages";
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ taffybarEnv ];
  allowSubstitutes = false;

  buildCommand = ''
    mkdir -p $out/bin
    makeWrapper ${taffybarEnv}/bin/taffybar $out/bin/taffybar \
      --set NIX_GHC "${taffybarEnv}/bin/ghc"
  '';

  # Trivial derivation
  preferLocalBuild = true;
  shellHook = "eval $(egrep ^export ${taffybarEnv}/bin/ghc)";
  # For hacking purposes
  passthru.env = taffybarEnv;
}
