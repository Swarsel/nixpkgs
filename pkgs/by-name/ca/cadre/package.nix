{
  lib,
  bundlerApp,
  bundlerUpdateScript,
}:

bundlerApp {
  pname = "cadre";
  exes = [ "cadre" ];
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "cadre";

  meta = {
    description = "Toolkit to add Ruby development - in-editor coverage, libnotify of test runs";
    homepage = "https://github.com/nyarly/cadre";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      nyarly
      nicknovitski
    ];

    platforms = lib.platforms.unix;
  };
}
