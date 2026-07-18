{
  lib,
  bundlerApp,
  bundlerUpdateScript,
  defaultGemConfig,
  nixosTests,
  ruby,
}:

bundlerApp {
  inherit ruby;
  pname = "oxidized";

  exes = [
    "oxidized"
    "oxs"
  ];

  gemConfig = defaultGemConfig;
  gemdir = ./.;

  passthru = {
    tests = nixosTests.oxidized;
    updateScript = bundlerUpdateScript "oxidized";
  };

  meta = {
    description = "Network device configuration backup tool. It's a RANCID replacement";
    homepage = "https://github.com/ytti/oxidized";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      nicknovitski
      liberodark
      johannwagner
    ];

    platforms = lib.platforms.linux;
  };
}
