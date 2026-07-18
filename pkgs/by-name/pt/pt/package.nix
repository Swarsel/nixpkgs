{
  lib,
  bundlerApp,
  bundlerUpdateScript,
}:

bundlerApp {
  pname = "pt";
  exes = [ "pt" ];
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "pt";

  meta = {
    description = "Minimalist command-line Pivotal Tracker client";
    homepage = "http://www.github.com/raul/pt";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      nicknovitski
    ];

    platforms = lib.platforms.unix;
    mainProgram = "pt";
  };
}
