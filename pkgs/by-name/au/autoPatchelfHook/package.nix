{
  lib,
  stdenv,
  auto-patchelf,
  bintools,
  makeSetupHook,
}:

makeSetupHook {
  propagatedBuildInputs = [
    auto-patchelf
    bintools
  ];

  name = "auto-patchelf-hook";

  substitutions = {
    hostPlatform = stdenv.hostPlatform.config;
  };

  meta = {
    maintainers = with lib.maintainers; [ layus ];
  };
} ./auto-patchelf.sh
