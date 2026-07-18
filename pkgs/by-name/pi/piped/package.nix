{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm_10,
  unstableGitUpdater,
}:
let
  pnpm = pnpm_10;
in
buildNpmPackage rec {
  pname = "piped";
  version = "0-unstable-2024-11-04";

  src = fetchFromGitHub {
    owner = "TeamPiped";
    repo = "piped";
    rev = "7866c06801baef16ce94d6f4dd0f8c1b8bc88153";
    hash = "sha256-o3TwE0s5rim+0VKR+oW9Rv3/eQRf2dgRQK4xjZ9pqCE=";
  };

  nativeBuildInputs = [ pnpm ];

  installPhase = ''
    runHook preInstall
    cp dist $out -r
    runHook postInstall
  '';

  npmConfigHook = pnpmConfigHook;
  npmDeps = pnpmDeps;

  pnpmDeps = fetchPnpmDeps {
    inherit
      pname
      version
      src
      pnpm
      ;

    fetcherVersion = 4;
    hash = "sha256-o5NKMMIVPkKiPx++ALcZ+3oN80DMQHPwQqGT4f4q5P8=";
  };

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Efficient and privacy-friendly YouTube frontend";
    homepage = "https://github.com/TeamPiped/Piped";
    license = [ lib.licenses.agpl3Plus ];
    maintainers = [ ];
  };

}
