{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  fixup-yarn-lock,
  nodejs,
  yarn,
  yarnBuildHook,
  yarnConfigHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lasuite-docs-frontend";
  version = "5.4.1";

  src = fetchFromGitHub {
    owner = "suitenumerique";
    repo = "docs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Xomq2i1t1POgggcAR8FAWf+Lr0y6YOKGvANFOv/BH20=";
  };

  nativeBuildInputs = [
    nodejs
    fixup-yarn-lock
    yarn
    yarnConfigHook
    yarnBuildHook
  ];

  installPhase = ''
    runHook preInstall

    cp -r apps/impress/out/ $out

    runHook postInstall
  '';

  offlineCache = fetchYarnDeps {
    hash = "sha256-r4uROroadFHALG8uHFPcvs8tCEdObx2rSVmxISxyyS8=";
    yarnLock = "${finalAttrs.src}/src/frontend/yarn.lock";
  };

  sourceRoot = "${finalAttrs.src.name}/src/frontend";
  yarnBuildScript = "app:build";

  meta = {
    description = "Collaborative note taking, wiki and documentation platform that scales. Built with Django and React. Opensource alternative to Notion or Outline";
    homepage = "https://github.com/suitenumerique/docs";
    changelog = "https://github.com/suitenumerique/docs/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      soyouzpanda
      ma27
    ];

    platforms = lib.platforms.linux;
  };
})
