{
  lib,
  bundlerApp,
  bundlerUpdateScript,
}:

bundlerApp {
  pname = "procodile";
  exes = [ "procodile" ];
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "procodile";

  meta = {
    description = "Run processes in the background (and foreground) on Mac & Linux from a Procfile (for production and/or development environments)";
    homepage = "https://github.com/adamcooke/procodile";
    license = with lib.licenses; mit;

    maintainers = with lib.maintainers; [
      nicknovitski
    ];

    platforms = lib.platforms.unix;
    mainProgram = "procodile";
  };
}
