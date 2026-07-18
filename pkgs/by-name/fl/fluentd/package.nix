{
  lib,
  bundlerEnv,
  bundlerUpdateScript,
  nixosTests,
  ruby,
}:

bundlerEnv {
  inherit ruby;
  pname = "fluentd";
  gemdir = ./.;
  passthru.tests.fluentd = nixosTests.fluentd;
  passthru.updateScript = bundlerUpdateScript "fluentd";

  meta = {
    description = "Data collector";
    homepage = "https://www.fluentd.org/";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      nicknovitski
    ];

    platforms = lib.platforms.unix;
  };
}
