{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  callPackage,
  nix-update-script,
  testers,
  xunit-viewer,
}:
let
  version = "10.6.1";
in
buildNpmPackage {
  inherit version;
  pname = "xunit-viewer";

  src = fetchFromGitHub {
    owner = "lukejpreston";
    repo = "xunit-viewer";
    rev = "v${version}";
    hash = "sha256-n9k1Z/wofExG6k/BxtkU8M+Lo3XdCgCh8VFj9jcwL1Q=";
  };

  npmDepsHash = "sha256-6PV0+G1gzUWUjOfwRtVeALVFFiwkCAB33yB9W0PCGfc=";

  passthru.tests = {
    version = testers.testVersion {
      version = "unknown"; # broken, but at least it runs
      package = xunit-viewer;
    };

    example = callPackage ./test/example.nix { };
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "View your xunit results using JavaScript";
    homepage = "https://lukejpreston.github.io/xunit-viewer";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ pluiedev ];
    platforms = lib.platforms.all;
  };
}
