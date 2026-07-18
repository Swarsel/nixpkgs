{
  lib,
  bundlerApp,
  bundlerUpdateScript,
}:

bundlerApp {
  pname = "neocities";
  exes = [ "neocities" ];
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "neocities";

  meta = {
    description = "CLI and library for interacting with the Neocities API";
    homepage = "https://github.com/neocities/neocities-ruby";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dawoox ];
    platforms = lib.platforms.unix;
    mainProgram = "neocities";
  };
}
