{
  lib,
  stdenv,
  fetchFromGitHub,
  cargo,
  cmake,
  fetchPnpmDeps,
  makeBinaryWrapper,
  nix-update-script,
  nodejs-slim,
  nodejs_24,
  pnpmConfigHook,
  pnpm_10,
  rustPlatform,
  rustc,
  versionCheckHook,
}:

# Build with pnpm instead of buildRustPackage because Prettier integration
# requires the JavaScript runtime and npm dependencies.
# A pure Rust build would lack the Prettier plugin functionality.
stdenv.mkDerivation (finalAttrs: {
  pname = "oxfmt";
  version = "0.58.0";

  src = fetchFromGitHub {
    owner = "oxc-project";
    repo = "oxc";
    tag = "oxfmt_v${finalAttrs.version}";
    hash = "sha256-sENfR27kqr/S25+43NiFEJsQrwYLqmuvTC/AhJETGsk=";
  };

  nativeBuildInputs = [
    cargo
    cmake
    makeBinaryWrapper
    nodejs_24
    pnpmConfigHook
    pnpm_10
    rustPlatform.cargoSetupHook
    rustc
  ];

  env.OXC_VERSION = finalAttrs.version;

  buildPhase = ''
    runHook preBuild

    pnpm --filter oxfmt-app run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    local outPath=$out/lib/oxfmt
    mkdir -p $outPath $out/bin

    # Reinstall production dependencies only
    find -name 'node_modules' -type d -exec rm -rf {} \; || true
    pnpm --filter oxfmt-app install --offline --prod --ignore-scripts

    cp -r apps/oxfmt/dist $outPath/
    cp -rL apps/oxfmt/node_modules $outPath/
    cp npm/oxfmt/configuration_schema.json $outPath/

    makeWrapper ${lib.getExe nodejs-slim} $out/bin/oxfmt \
      --add-flags $outPath/dist/cli.js

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-RkZ6e07SnJArjL0CNo5Qfo/hYrw1HIM4g8bvMJm9ypE=";
  };

  # cmake is only needed for libmimalloc-sys2 crate, not for top-level build
  dontUseCmakeConfigure = true;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-eSPMGwkgpNgyPS4eebGoGi+gu9xqw8OWGvK7DK2goMk=";
    pnpm = pnpm_10;
  };

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex=^oxfmt_v([0-9.]+)$" ];
  };

  meta = {
    inherit (nodejs-slim.meta) platforms;
    description = "High-performance formatter for the JavaScript ecosystem";
    homepage = "https://oxc.rs/docs/guide/usage/formatter";
    changelog = "https://github.com/oxc-project/oxc/blob/${finalAttrs.src.tag}/apps/oxfmt/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ natsukium ];
    mainProgram = "oxfmt";
    downloadPage = "https://github.com/oxc-project/oxc";
  };
})
