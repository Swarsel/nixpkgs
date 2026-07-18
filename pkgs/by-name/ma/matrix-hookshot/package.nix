{
  lib,
  stdenv,
  fetchFromGitHub,
  cargo,
  fetchYarnDeps,
  makeWrapper,
  matrix-sdk-crypto-nodejs,
  napi-rs-cli,
  nix-update-script,
  nodejs,
  openssl,
  pkg-config,
  rustPlatform,
  rustc,
  yarnConfigHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "matrix-hookshot";
  version = "7.3.3";

  src = fetchFromGitHub {
    owner = "matrix-org";
    repo = "matrix-hookshot";
    tag = finalAttrs.version;
    hash = "sha256-SVQsXzQU3TTiKjd1manEsqL/Ui6s/sFoZPBf9mWp31k=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    yarnConfigHook
    pkg-config
    cargo
    rustc
    napi-rs-cli
    makeWrapper
    nodejs
  ];

  buildInputs = [ openssl ];

  preBuild = ''
    # We want nixpkgs' version of this instead
    rm -rf node_modules/@matrix-org/matrix-sdk-crypto-nodejs
    cp -r ${matrix-sdk-crypto-nodejs}/lib/node_modules/@matrix-org/matrix-sdk-crypto-nodejs \
      node_modules/@matrix-org/matrix-sdk-crypto-nodejs
    chmod -R a+rwx node_modules/@matrix-org/matrix-sdk-crypto-nodejs
  '';

  buildPhase = ''
    runHook preBuild

    yarn run build:app:rs --target ${stdenv.hostPlatform.rust.rustcTargetSpec}
    yarn run build:app:fix-defs
    yarn run build:app
    yarn run build:web

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    rm -rf ./node_modules
    yarn install --production --offline --force --ignore-engines --no-bin-links --frozen-lockfile

    # Re-install matrix-sdk-crypto-nodejs
    rm -rf node_modules/@matrix-org/matrix-sdk-crypto-nodejs
    cp -r ${matrix-sdk-crypto-nodejs}/lib/node_modules/@matrix-org/matrix-sdk-crypto-nodejs \
      node_modules/@matrix-org/matrix-sdk-crypto-nodejs
    chmod -R a+rwx node_modules/@matrix-org/matrix-sdk-crypto-nodejs

    mkdir -p $out/lib/node_modules/matrix-hookshot/
    mkdir $out/bin

    mv ./lib/* $out/lib/node_modules/matrix-hookshot
    mv ./public ./assets ./node_modules ./package.json $out/lib/node_modules/matrix-hookshot

    runHook postInstall
  '';

  postInstall = ''
    makeWrapper '${lib.getExe nodejs}' "$out/bin/matrix-hookshot" \
      --set NODE_ENV "production" \
      --add-flags "$out/lib/node_modules/matrix-hookshot/App/BridgeApp.js"
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-EMwrIo17d5+LTczv4/+4m6XALfH0dCHnWtBU17h+mxI=";
  };

  offlineCache = fetchYarnDeps {
    inherit (finalAttrs) src;
    hash = "sha256-1J2a0ZRARYOEQE70WnKZlgwjIwafPfmgBtUVXX106lg=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Bridge between Matrix and multiple project management services, such as GitHub, GitLab and JIRA";
    homepage = "https://matrix-org.github.io/matrix-hookshot/";
    changelog = "https://github.com/matrix-org/matrix-hookshot/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ chvp ];
    platforms = lib.platforms.linux;
    mainProgram = "matrix-hookshot";
  };
})
