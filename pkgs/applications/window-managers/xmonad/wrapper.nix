{
  stdenv,
  ghcWithPackages,
  makeWrapper,
  packages,
  xmessage,
}:

let
  xmonadEnv = ghcWithPackages (self: [ self.xmonad ] ++ packages self);
in
stdenv.mkDerivation {
  inherit (xmonadEnv) version;
  pname = "xmonad-with-packages";
  nativeBuildInputs = [ makeWrapper ];
  allowSubstitutes = false;

  buildCommand = ''
    install -D ${xmonadEnv}/share/man/man1/xmonad.1.gz $out/share/man/man1/xmonad.1.gz
    makeWrapper ${xmonadEnv}/bin/xmonad $out/bin/xmonad \
      --set XMONAD_GHC "${xmonadEnv}/bin/ghc" \
      --set XMONAD_XMESSAGE "${xmessage}/bin/xmessage"
  '';

  # trivial derivation
  preferLocalBuild = true;
}
