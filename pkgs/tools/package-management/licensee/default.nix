{
  lib,
  bundlerApp,
  bundlerUpdateScript,
}:

bundlerApp {
  pname = "licensee";
  exes = [ "licensee" ];
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "licensee";

  meta = {
    description = "Ruby Gem to detect under what license a project is distributed";
    homepage = "https://licensee.github.io/licensee/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sternenseemann ];
    platforms = lib.platforms.unix;
    mainProgram = "licensee";
  };
}
