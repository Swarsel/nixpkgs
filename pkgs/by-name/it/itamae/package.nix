{
  lib,
  bundlerApp,
  bundlerUpdateScript,
}:

bundlerApp {
  pname = "itamae";
  exes = [ "itamae" ];
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "itamae";

  meta = {
    description = "Simple and lightweight configuration management tool inspired by Chef";
    homepage = "https://itamae.kitchen/";
    license = with lib.licenses; mit;
    maintainers = with lib.maintainers; [ refi64 ];
    platforms = lib.platforms.unix;
    mainProgram = "itamae";
  };
}
