{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nix-update-script,
  nixosTests,
}:

buildNpmPackage rec {
  pname = "cross-seed";
  version = "6.13.7";

  src = fetchFromGitHub {
    owner = "cross-seed";
    repo = "cross-seed";
    tag = "v${version}";
    hash = "sha256-+7A4UGIY75hvF0JvtIr6nGNdXkUE0XV9TFpEQz9OW+Y=";
  };

  npmDepsHash = "sha256-HoIiO7cj4JNY+sJEuH1v0AgagDuBTySJaoVo/4SsfIc=";

  passthru = {
    tests.cross-seed = nixosTests.cross-seed;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Fully-automatic torrent cross-seeding with Torznab";
    homepage = "https://cross-seed.org";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ mkez ];
    mainProgram = "cross-seed";
  };
}
