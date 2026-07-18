{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nix-update-script,
  nodejs_22,
}:

buildNpmPackage rec {
  pname = "ares-cli";
  version = "3.2.4";

  src = fetchFromGitHub {
    owner = "webos-tools";
    repo = "cli";
    rev = "v${version}";
    hash = "sha256-dM8o/mK8AbQNCE6UrSWyOkL5c3G25j3NfoDYJ6X7irg=";
  };

  npmDepsHash = "sha256-18sZW5yBDkEUlDgAERAsUQCOUOaBao6+wHOM9TCAlms=";
  dontNpmBuild = true;
  nodejs = nodejs_22;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Collection of commands used for creating, packaging, installing, and launching web apps for LG webOS TV";

    longDescription = ''
      webOS CLI (Command Line Interface) provides a collection of commands used for creating, packaging, installing,
      and launching web apps in the command line environment. The CLI allows you to develop and test your app without using
      a specific IDE.
    '';

    homepage = "https://webostv.developer.lge.com/develop/tools/cli-introduction";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ rucadi ];
    mainProgram = "ares";
  };
}
