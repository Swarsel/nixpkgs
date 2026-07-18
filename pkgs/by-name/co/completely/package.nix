{
  lib,
  bundlerApp,
  bundlerUpdateScript,
}:

bundlerApp {
  pname = "completely";
  exes = [ "completely" ];
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "completely";

  meta = {
    description = "Generate bash completion scripts using a simple configuration file";
    homepage = "https://github.com/DannyBen/completely";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ zendo ];
    platforms = lib.platforms.unix;
    mainProgram = "completely";
  };
}
