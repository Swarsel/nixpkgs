{
  lib,
  bundlerApp,
  bundlerUpdateScript,
  callPackage,
}:

bundlerApp rec {
  pname = "maid";
  exes = [ "maid" ];
  gemdir = ./.;
  passthru.tests.run = callPackage ./test.nix { };
  passthru.updateScript = bundlerUpdateScript pname;

  meta = {
    description = "Rule-based file mover and cleaner in Ruby";
    homepage = "https://github.com/maid/maid";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ alinnow ];
    platforms = lib.platforms.unix;
  };
}
