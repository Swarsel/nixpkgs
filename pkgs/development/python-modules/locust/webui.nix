{
  lib,
  stdenv,
  nodejs,
  src,
  version,
  yarn-berry_4,
}:
let
  yarn-berry = yarn-berry_4;
in
stdenv.mkDerivation (finalAttrs: {
  inherit version src;
  pname = "locust-ui";

  patches = [
    # Remove after upstream updates to Yarn 4.14
    # https://github.com/locustio/locust/blob/master/locust/webui/package.json#L89
    ./yarn-4.14-support.patch
  ];

  nativeBuildInputs = [
    yarn-berry
    yarn-berry.yarnBerryConfigHook
    nodejs
  ];

  buildPhase = ''
    runHook preBuild
    yarn build
    runHook postBuild
  '';

  postInstall = ''
    mkdir -p $out/dist
    cp -r dist/** $out/dist
  '';

  dontNpmPrune = true;
  missingHashes = ./missing-hashes.json;

  yarnOfflineCache = yarn-berry.fetchYarnBerryDeps {
    inherit (finalAttrs) src missingHashes patches;
    hash = "sha256-4iRQYw1MrIoY0h939h86F2AROKxpfIXSqr/m0IYS3Jg=";
  };
})
