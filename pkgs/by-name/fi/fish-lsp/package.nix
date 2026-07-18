{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  fish,
  installShellFiles,
  makeWrapper,
  nix-update-script,
  nodejs,
  npmHooks,
  testers,
  which,
  yarnBuildHook,
  yarnConfigHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "fish-lsp";
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "ndonfris";
    repo = "fish-lsp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kPGbEi0KCq/BsEq2RkFb5zfARncMIvXHniOUglNYk1s=";
  };

  nativeBuildInputs = [
    yarnBuildHook
    yarnConfigHook
    npmHooks.npmInstallHook
    nodejs
    installShellFiles
    makeWrapper
    fish
  ];

  installPhase = ''
    runHook preInstall

    rm -rf node_modules
    yarn install --frozen-lockfile --force --production=true --ignore-engines \
      --ignore-platform --ignore-scripts --no-progress --non-interactive --offline

    mkdir -p $out/share/fish-lsp
    cp -r . $out/share/fish-lsp

    makeWrapper ${lib.getExe nodejs} "$out/bin/fish-lsp" \
      --add-flags "$out/share/fish-lsp/dist/fish-lsp" \
      --prefix PATH : "${
        lib.makeBinPath [
          fish
          which
        ]
      }"

    ${lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      installShellCompletion --cmd fish-lsp \
        --fish <($out/bin/fish-lsp complete --fish)
    ''}

    runHook postInstall
  '';

  doDist = false;
  yarnBuildScript = "build:npm";

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-WrH56oWTTDG1P/OHC5WjLCkZM3j6HEirAvhF+6Xd76I=";
    yarnLock = finalAttrs.src + "/yarn.lock";
  };

  passthru = {
    tests = {
      version = testers.testVersion {
        version = finalAttrs.version;
        package = finalAttrs.finalPackage;
      };
    };

    # fish-lsp adds tags for all its pre-release versions, which leads to
    # incorrect r-ryantm bumps. This regex allows a dash at the end followed by a
    # number (like `v1.0.9-1`). but it prevents matches with a dash followed by
    # text (like `v1.0.11-pre.10`). or, of course, no dash at all
    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "v(\\d+\\.\\d+\\.\\d+(?:-\\d+)?)$"
      ];
    };
  };

  meta = {
    description = "LSP implementation for the fish shell language";
    homepage = "https://github.com/ndonfris/fish-lsp";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      llakala
      petertriho
    ];

    platforms = lib.platforms.unix;
    mainProgram = "fish-lsp";
  };
})
