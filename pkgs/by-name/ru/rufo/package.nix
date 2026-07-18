{
  lib,
  bundlerApp,
  bundlerUpdateScript,
}:

bundlerApp {
  pname = "rufo";
  exes = [ "rufo" ];
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "rufo";

  meta = {
    description = "Ruby formatter";
    homepage = "https://github.com/ruby-formatter/rufo";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ andersk ];
    mainProgram = "rufo";
  };
}
