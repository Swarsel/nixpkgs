{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  faketty,
  fetchYarnDeps,
  fixup-yarn-lock,
  go,
  makeWrapper,
  nix-update-script,
  nodejs,
  patchelf,
  removeReferencesTo,
  testers,
  versionCheckHook,
  yarn,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cdktn-cli";
  version = "0.23.3";

  src = fetchFromGitHub {
    owner = "open-constructs";
    repo = "cdk-terrain";
    tag = "v${finalAttrs.version}";
    hash = "sha256-k3xAaJiqldRZubAFrRuNM1e+3kH/5vv0maEeT/gdqK0=";
  };

  postPatch = ''
    # wasm_exec has moved to lib in newer versions of Go
    substituteInPlace packages/@cdktn/hcl-tools/prebuild.sh \
      --replace-fail "misc/wasm/wasm_exec.js" "lib/wasm/wasm_exec.js"
    substituteInPlace packages/@cdktn/hcl2json/prebuild.sh \
      --replace-fail "misc/wasm/wasm_exec.js" "lib/wasm/wasm_exec.js"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    faketty
    fixup-yarn-lock
    go
    makeWrapper
    nodejs
    patchelf
    removeReferencesTo
    yarn
  ];

  preConfigure = ''
    export GOCACHE=$TMPDIR/go-cache
    export GOPATH=$TMPDIR/go
    export GOPROXY=file://${finalAttrs.hcltools-go-modules},file://${finalAttrs.hcl2json-go-modules}
    export GOSUMDB=off

    # Stop the build from trying to write checkpoints to /var/empty/
    export CHECKPOINT_DISABLE=1
  '';

  buildPhase = ''
    runHook preBuild

    bash ./tools/align-version.sh

    faketty yarn --offline build

    runHook postBuild
  '';

  doCheck = true;

  checkPhase = ''
    runHook preCheck

    # Skip tests that require terraform (unfree)
    yarn --offline workspace cdktn-cli jest \
      --testPathIgnorePatterns \
       "src/test/cmds/(convert|init).test.ts"

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    yarn --offline --production install

    mkdir -p "$out/lib/node_modules/cdktn-cli"
    cp -rL node_modules packages/cdktn-cli/bundle packages/cdktn-cli/package.json "$out/lib/node_modules/cdktn-cli/"

    makeWrapper "${lib.getExe nodejs}" "$out/bin/cdktn" \
      --add-flags "--no-warnings=DEP0040" \
      --add-flags "$out/lib/node_modules/cdktn-cli/bundle/bin/cdktn.js"

    runHook postInstall
  '';

  postInstall = ''
    # Go isn't needed at runtime, so remove these to decrease the closure size
    remove-references-to -t ${go} \
      "$out/lib/node_modules/cdktn-cli/node_modules/@cdktn/hcl-tools/main.wasm" \
      "$out/lib/node_modules/cdktn-cli/node_modules/@cdktn/hcl2json/main.wasm"
  '';

  # Tries to write to /var/empty/.terraform.d on darwin
  # even with writableTmpDirAsHomeHook and CHECKPOINT_DISABLE=1
  doInstallCheck = stdenv.hostPlatform.isLinux;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  configurePhase = ''
    runHook preConfigure

    export HOME=$(mktemp -d)
    yarn config --offline set yarn-offline-mirror $offlineCache
    fixup-yarn-lock yarn.lock
    yarn --offline --frozen-lockfile --ignore-platform --ignore-scripts --no-progress --non-interactive install
    patchShebangs node_modules packages

    runHook postConfigure
  '';

  disallowedReferences = [ go ];

  hcl2json-go-modules =
    (buildGoModule {
      inherit (finalAttrs) version src;
      pname = "cdktn-hcl2json-go-modules";
      vendorHash = "sha256-OiKPq0CHkOxJaFzgsaNJ02tasvHtHWylmaPRPayJob4=";
      env.GOWORK = "off";
      doCheck = false;
      modRoot = "packages/@cdktn/hcl2json";
      proxyVendor = true;
    }).goModules;

  hcltools-go-modules =
    (buildGoModule {
      inherit (finalAttrs) version src;
      pname = "cdktn-hcltools-go-modules";
      vendorHash = "sha256-orGxkYEQVtTKvXb7/FD/CLwqSINgBQFTF5arbR0xAvE=";
      env.GOWORK = "off";
      doCheck = false;
      modRoot = "packages/@cdktn/hcl-tools";
      proxyVendor = true;
    }).goModules;

  offlineCache = fetchYarnDeps {
    hash = "sha256-9nhv31ljJ8DphOot3TAsYhbV6cx7Ovfe+ll+V2vJWx8=";
    yarnLock = "${finalAttrs.src}/yarn.lock";
  };

  passthru.updateScript = nix-update-script {
    # Skip pre-releases
    extraArgs = [
      "--version-regex"
      "^v([\\d.]+)$"
    ];
  };

  meta = {
    description = "CDK for Terraform CLI";
    homepage = "https://cdktn.io";
    changelog = "https://github.com/open-constructs/cdk-terrain/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ deejayem ];
    platforms = lib.platforms.unix;
    mainProgram = "cdktn";
  };
})
