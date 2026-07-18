{
  lib,
  stdenv,
  fetchFromGitHub,
  gitMinimal,
  nodejs,
  npmHooks,
  yarn-berry_4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "advanced-camera-card";
  version = "7.27.4";

  src = fetchFromGitHub {
    owner = "dermotduffy";
    repo = "advanced-camera-card";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NdWP2nYzDEzmO4DpwVUpn3/KsungKNOzOQf8FxZ4fGw=";
  };

  patches = [
    # Remove after upstream updates to Yarn 4.14
    # https://github.com/dermotduffy/advanced-camera-card/blob/main/package.json#L201
    ./yarn-4.14-support.patch

    # Drop hard dependency on .git repo during build
    ./gitinfo.patch
  ];

  postPatch = ''
    substituteInPlace package.json \
      --replace-fail "0.0.0-dev" "${finalAttrs.version}"
  '';

  nativeBuildInputs = [
    gitMinimal
    nodejs
    npmHooks.npmBuildHook
    yarn-berry_4
    yarn-berry_4.yarnBerryConfigHook
  ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -rv dist/* $out/

    runHook postInstall
  '';

  missingHashes = ./missing-hashes.json;
  npmBuildScript = "build";

  offlineCache = yarn-berry_4.fetchYarnBerryDeps {
    inherit (finalAttrs) src missingHashes patches;
    hash = "sha256-4fdSeSxSjd8EjPmu7U3ftxB+OJJc2uuvM3Umr5iY/a8=";
    name = "${finalAttrs.pname}-yarn-deps";
  };

  meta = {
    description = "Comprehensive camera card for Home Assistant";
    homepage = "https://github.com/dermotduffy/advanced-camera-card";
    changelog = "https://github.com/dermotduffy/advanced-camera-card/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
