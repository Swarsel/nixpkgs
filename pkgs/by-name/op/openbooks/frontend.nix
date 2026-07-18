{
  buildNpmPackage,
  callPackage,
}:
let
  common = callPackage ./common.nix { };
in
buildNpmPackage {
  inherit (common) version;
  pname = "openbooks-frontend";
  src = "${common.src}/server/app";
  npmDepsHash = "sha256-OtXPOFK18b6tzFIvXkThafLUw0GlioRmxjzcKYeTalU=";

  installPhase = ''
    runHook preInstall

    cp -r dist $out

    runHook postInstall
  '';

  meta = common.meta // {
    description = "Openbooks frontend";
  };
}
