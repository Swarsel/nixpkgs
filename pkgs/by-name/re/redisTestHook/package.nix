{
  lib,
  callPackage,
  makeSetupHook,
  python3Packages,
  valkey,
}:

makeSetupHook {
  name = "redis-test-hook";

  substitutions = {
    cli = lib.getExe' valkey "redis-cli";
    server = lib.getExe' valkey "redis-server";
  };

  passthru.tests = {
    python3-valkey = python3Packages.valkey;
    simple = callPackage ./test.nix { };
  };

  meta = {
    license = lib.licenses.mit;
    teams = [ lib.teams.redis ];
  };
} ./redis-test-hook.sh
