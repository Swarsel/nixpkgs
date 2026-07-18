{
  lib,
  makeSetupHook,
  teensy-cmake-macros,
}:

makeSetupHook {
  propagatedBuildInputs = [ teensy-cmake-macros ];
  name = "teensy-cmake-macros-hook";
  passthru = { inherit teensy-cmake-macros; };

  meta = {
    inherit (teensy-cmake-macros.meta) maintainers platforms broken;
    description = "Setup hook for teensy-cmake-macros";
    license = lib.licenses.mit;
  };
} ./setup-hook.sh
