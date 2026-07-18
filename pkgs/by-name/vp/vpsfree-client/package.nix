{
  lib,
  bundlerApp,
  bundlerUpdateScript,
}:

bundlerApp {
  pname = "vpsfree-client";
  exes = [ "vpsfreectl" ];
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "vpsfree-client";

  meta = {
    description = "Ruby API and CLI for the vpsFree.cz API";
    homepage = "https://github.com/vpsfreecz/vpsfree-client";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      aither64
      zimbatm
    ];

    platforms = lib.platforms.unix;
    mainProgram = "vpsfreectl";
  };
}
