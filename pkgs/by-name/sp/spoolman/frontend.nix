{ buildNpmPackage, callPackage }:
let
  common = callPackage ./common.nix { };
in

buildNpmPackage {
  inherit (common) version;
  pname = "spoolman-frontend";
  src = "${common.src}/client";
  npmDepsHash = "sha256-8ojD7xMxRE9+b4O7vJdwKwrg8aYukYc3l+LF5enKFgA=";
  installPhase = "cp -r dist $out";
  VITE_APIURL = "/api/v1";

  meta = common.meta // {
    description = "Spoolman frontend";
    mainProgram = "spoolman-frontend";
  };
}
