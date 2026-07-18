{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  fetchPnpmDeps,
  nix-update-script,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
}:
let
  pnpm = pnpm_10;
in
buildNpmPackage (finalAttrs: {
  pname = "sub-store-frontend";
  version = "2.28.6";

  src = fetchFromGitHub {
    owner = "sub-store-org";
    repo = "Sub-Store-Front-End";
    tag = finalAttrs.version;
    hash = "sha256-dCby4fKCx9lzlSdn9TZwOsQWPFf36ZcL5bEg3XgipjY=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm
  ];

  installPhase = ''
    runHook preInstall

    cp -r dist $out

    runHook postInstall
  '';

  npmConfigHook = pnpmConfigHook;
  npmDeps = null;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-lj93WF3mqvgaD0qnZC+X4ubw8ohz8E5ICWYWbEITYnk=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Sub-Store Progressive Web App";
    homepage = "https://github.com/sub-store-org/Sub-Store-Front-End";
    changelog = "https://github.com/sub-store-org/Sub-Store-Front-End/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = nodejs.meta.platforms;
  };
})
