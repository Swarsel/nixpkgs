{
  lib,
  bundlerApp,
}:

bundlerApp {
  pname = "ceedling";
  exes = [ "ceedling" ];
  gemdir = ./.;

  meta = {
    description = "Build system for C projects that is something of an extension around Ruby's Rake";
    homepage = "https://www.throwtheswitch.org/ceedling";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.rlwrnc ];
    platforms = lib.platforms.unix;
    mainProgram = "ceedling";
  };
}
