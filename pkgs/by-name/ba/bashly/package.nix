{
  lib,
  bundlerApp,
  bundlerUpdateScript,
}:

bundlerApp {
  pname = "bashly";
  exes = [ "bashly" ];
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "bashly";

  meta = {
    description = "Bash command line framework and CLI generator";
    homepage = "https://github.com/DannyBen/bashly";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "bashly";
  };
}
