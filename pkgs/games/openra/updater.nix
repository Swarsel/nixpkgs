{
  lib,
  common-updater-scripts,
  curl,
  gnused,
  jq,
  nix,
  nix-prefetch-github,
  writeShellApplication,
}:
engine:

lib.getExe (writeShellApplication {
  bashOptions = [
    "errexit"
    "errtrace"
    "nounset"
    "pipefail"
  ];

  name = "openra-updater";

  runtimeEnv = {
    build = engine.build;
    currentRev = lib.optionalString (lib.hasAttr "rev" engine) engine.rev;
    currentVersion = engine.version;
  };

  runtimeInputs = [
    curl
    jq
    gnused
    nix
    nix-prefetch-github
    common-updater-scripts
  ];

  text = lib.readFile ./updater.sh;
})
