{
  lib,
  buildNpmPackage,
  fetchPnpmDeps,
  nodejs,
  picoclaw,
  pnpmConfigHook,
  pnpm_10,
}:
let
  pnpm = pnpm_10;
in
buildNpmPackage (finalAttrs: {
  inherit (picoclaw) src version;
  pname = "picoclaw-launcher-frontend";

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
    inherit (finalAttrs)
      pname
      version
      src
      sourceRoot
      ;

    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-ECZBq/miLE9dkEOx8e8WI68tI0HBb+iFVeztwMVeeKw=";
  };

  sourceRoot = "${finalAttrs.src.name}/web/frontend";
  meta = lib.removeAttrs picoclaw.meta [ "mainProgram" ];
})
