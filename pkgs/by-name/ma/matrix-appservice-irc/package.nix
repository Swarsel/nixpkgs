{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  fixup-yarn-lock,
  matrix-sdk-crypto-nodejs,
  nix-update-script,
  nixosTests,
  node-gyp-build,
  nodejs-slim_22,
  yarn,
}:

let
  pname = "matrix-appservice-irc";
  version = "4.0.0";

  src = fetchFromGitHub {
    owner = "matrix-org";
    repo = "matrix-appservice-irc";
    tag = version;
    hash = "sha256-bM1CUuFRBOg/4y50gI7ZLwnrbBU6pZlqyitTI2WeVsA=";
  };

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-JHSHhkfDGAra6Lq2QB5ngkLo1jR+vrWeux+LYORciZ8=";
    name = "${pname}-${version}-offline-cache";
    yarnLock = "${src}/yarn.lock";
  };

in
stdenv.mkDerivation {
  inherit
    pname
    version
    src
    yarnOfflineCache
    ;

  strictDeps = true;

  nativeBuildInputs = [
    fixup-yarn-lock
    nodejs-slim_22
    yarn
    node-gyp-build
  ];

  buildPhase = ''
    runHook preBuild

    yarn --offline build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp package.json $out
    cp app.js config.schema.yml $out
    cp -r bin lib public $out

    # prune dependencies to production only
    yarn install --frozen-lockfile --offline --no-progress --non-interactive --ignore-scripts --production
    cp -r node_modules $out

    # replace matrix-sdk-crypto-nodejs with nixos package
    rm -rv $out/node_modules/@matrix-org/matrix-sdk-crypto-nodejs
    ln -sv ${matrix-sdk-crypto-nodejs}/lib/node_modules/@matrix-org/matrix-sdk-crypto-nodejs $out/node_modules/@matrix-org/

    runHook postInstall
  '';

  configurePhase = ''
    runHook preConfigure

    export HOME=$(mktemp -d)
    yarn config --offline set yarn-offline-mirror "$yarnOfflineCache"
    fixup-yarn-lock yarn.lock
    yarn install --frozen-lockfile --offline --no-progress --non-interactive --ignore-scripts
    patchShebangs node_modules/ bin/

    runHook postConfigure
  '';

  passthru.tests.matrix-appservice-irc = nixosTests.matrix-appservice-irc;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Node.js IRC bridge for Matrix";
    homepage = "https://github.com/matrix-org/matrix-appservice-irc";
    changelog = "https://github.com/matrix-org/matrix-appservice-irc/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ rhysmdnz ];
    platforms = lib.platforms.linux;
    mainProgram = "matrix-appservice-irc";
  };
}
