{
  lib,
  stdenv,
  ghcWithPackages,
  haskellPackages,
  ...
}:

let
  xmonadctlEnv = ghcWithPackages (self: [
    self.xmonad-contrib
    self.X11
  ]);
in
stdenv.mkDerivation {
  inherit (haskellPackages.xmonad-contrib) src version;
  pname = "xmonadctl";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    ${xmonadctlEnv}/bin/ghc -o $out/bin/xmonadctl \
      --make scripts/xmonadctl.hs
    runHook postInstall
  '';

  meta = {
    description = "Send commands to a running instance of xmonad";
    homepage = "https://github.com/xmonad/xmonad-contrib";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.ajgrf ];
    platforms = lib.platforms.unix;
    mainProgram = "xmonadctl";
  };
}
