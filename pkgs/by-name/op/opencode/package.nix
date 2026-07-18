{
  lib,
  fetchFromGitHub,
  bun,
  installShellFiles,
  makeBinaryWrapper,
  models-dev,
  nix-update-script,
  nodejs,
  ripgrep,
  stdenvNoCC,
  sysctl,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "opencode";
  version = "1.17.20";

  src = fetchFromGitHub {
    owner = "anomalyco";
    repo = "opencode";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gHfkwCi6Kjn5ppsuyhyM2vyaLmAoNdWth6Xz4LaV7Hk=";
  };

  postPatch = ''
    # NOTE: Relax Bun version check to be a warning instead of an error
    substituteInPlace packages/script/src/index.ts \
      --replace-fail 'throw new Error(`This script requires bun@''${expectedBunVersionRange}' \
                     'console.warn(`Warning: This script requires bun@''${expectedBunVersionRange}'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    bun
    nodejs
    installShellFiles
    makeBinaryWrapper
    writableTmpDirAsHomeHook
  ];

  env.MODELS_DEV_API_JSON = "${models-dev}/dist/_api.json";
  env.OPENCODE_CHANNEL = "stable";
  env.OPENCODE_DISABLE_MODELS_FETCH = true;
  env.OPENCODE_VERSION = finalAttrs.version;

  buildPhase = ''
    runHook preBuild

    cd ./packages/opencode
    bun --bun ./script/build.ts --single --skip-install
    bun --bun ./script/schema.ts config.json tui.json

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 dist/opencode-*/bin/opencode $out/bin/opencode
    wrapProgram $out/bin/opencode \
     --prefix PATH : ${
       lib.makeBinPath (
         [
           ripgrep
         ]
         ++ lib.optionals stdenvNoCC.hostPlatform.isDarwin [
           sysctl
         ]
       )
     } \
    --set OPENCODE_DISABLE_AUTOUPDATE true

    install -Dm644 config.json $out/share/opencode/config.json
    install -Dm644 tui.json $out/share/opencode/tui.json

    runHook postInstall
  '';

  postInstall = lib.optionalString (stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform) ''
    installShellCompletion --cmd opencode \
      --bash <($out/bin/opencode completion) \
      --zsh <(SHELL=/bin/zsh $out/bin/opencode completion)
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];

  __structuredAttrs = true;

  configurePhase = ''
    runHook preConfigure

    cp -R ${finalAttrs.node_modules}/. .
    patchShebangs node_modules
    patchShebangs packages/*/node_modules

    runHook postConfigure
  '';

  node_modules = stdenvNoCC.mkDerivation {
    inherit (finalAttrs) version src;
    pname = "${finalAttrs.pname}-node_modules";

    nativeBuildInputs = [
      bun
      writableTmpDirAsHomeHook
    ];

    buildPhase = ''
      runHook preBuild

      export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
      bun install \
        --cpu="*" \
        --frozen-lockfile \
        --filter ./ \
        --filter ./packages/app \
        --filter ./packages/desktop \
        --filter ./packages/opencode \
        --filter ./packages/shared \
        --ignore-scripts \
        --no-progress \
        --os="*"

      bun --bun ./nix/scripts/canonicalize-node-modules.ts
      bun --bun ./nix/scripts/normalize-bun-binaries.ts

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      find . -type d -name node_modules -exec cp -R --parents {} $out \;

      runHook postInstall
    '';

    dontConfigure = true;
    # NOTE: Required else we get errors that our fixed-output derivation references store paths
    dontFixup = true;

    impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
      "GIT_PROXY_COMMAND"
      "SOCKS_SERVER"
    ];

    outputHash = "sha256-3NAzmlzVBcLSRXxpNOyW5DKfD1i2HReST2jlKgrtOKc=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  versionCheckKeepEnvironment = [
    "HOME"
    "OPENCODE_DISABLE_MODELS_FETCH"
  ];

  versionCheckProgramArg = "--version";

  passthru = {
    jsonschema = {
      config = "${finalAttrs.finalPackage}/share/opencode/config.json";
      tui = "${finalAttrs.finalPackage}/share/opencode/tui.json";
    };

    updateScript = nix-update-script {
      extraArgs = [
        "--subpackage"
        "node_modules"
      ];
    };
  };

  meta = {
    description = "AI coding agent built for the terminal";
    homepage = "https://github.com/anomalyco/opencode";
    changelog = "https://github.com/anomalyco/opencode/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];

    maintainers = with lib.maintainers; [
      delafthi
      DuskyElf
      graham33
    ];

    platforms = [
      "aarch64-linux"
      "x86_64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "opencode";
  };
})
