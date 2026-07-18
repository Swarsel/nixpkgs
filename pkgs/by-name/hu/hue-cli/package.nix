{
  lib,
  bundlerApp,
  bundlerUpdateScript,
}:

bundlerApp {
  pname = "hue-cli";
  exes = [ "hue" ];
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "hue-cli";

  meta = {
    description = "Command line interface for controlling Philips Hue system's lights and bridge";
    homepage = "https://github.com/birkirb/hue-cli";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      nicknovitski
    ];

    platforms = lib.platforms.unix;
    mainProgram = "hue";
  };
}
