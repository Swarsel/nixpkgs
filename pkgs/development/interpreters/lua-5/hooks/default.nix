# Hooks for building lua packages.
{
  lib,
  lua,
  makeSetupHook,
}:

let
  callPackage = lua.pkgs.callPackage;
in
{
  /**
    Accepts "bustedFlags" as an array.
    You can customize the call by setting "bustedFlags" and prevent the test from running by setting "dontBustedCheck"
  */
  bustedCheckHook = callPackage (
    { busted }:
    makeSetupHook {
      propagatedBuildInputs = [
        busted
      ];

      name = "busted-check-hook";
      meta.license = lib.licenses.mit;
    } ./busted-check-hook.sh
  ) { };

  luarocksCheckHook = callPackage (
    { luarocks }:
    makeSetupHook {
      propagatedBuildInputs = [ luarocks ];
      name = "luarocks-check-hook";
      meta.license = lib.licenses.mit;
    } ./luarocks-check-hook.sh
  ) { };

  # luarocks installs data in a non-overridable location. Until a proper luarocks patch,
  # we move the files around ourselves
  luarocksMoveDataFolder = makeSetupHook {
    name = "luarocks-move-rock";
    meta.license = lib.licenses.mit;
  } ./luarocks-move-data.sh;
}
