{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  nix-update-script,
  nixosTests,
  nodejs_22,
  perl,
  versionCheckHook,
  writableTmpDirAsHomeHook,
  xcbuild,
}:

buildNpmPackage (finalAttrs: {
  pname = "bitwarden-cli";
  version = "2026.6.0";

  src = fetchFromGitHub {
    owner = "bitwarden";
    repo = "clients";
    tag = "cli-v${finalAttrs.version}";
    hash = "sha256-JIIis3wW0cU33ovRQfJi3HlB2YdLZ5IPvueq1dGFbas=";
  };

  postPatch = ''
    # remove code under unfree license
    rm -r bitwarden_license
  '';

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    perl
    xcbuild.xcrun
  ];

  npmDepsHash = "sha256-sXFSjQw9iM5Ye03BX+ZzpDfeAyLTJoG/k46NiI3O8+A=";

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    npm_config_build_from_source = "true";
  };

  postConfigure = ''
    # we want to build everything from source
    shopt -s globstar
    rm -r node_modules/**/prebuilds
    shopt -u globstar

    npm rebuild --verbose
  '';

  postBuild = ''
    # remove build artifacts that bloat the closure
    shopt -s globstar
    rm -r node_modules/**/{*.target.mk,binding.Makefile,config.gypi,Makefile,Release/.deps}
    shopt -u globstar
  '';

  postInstall = ''
    # The @bitwarden modules are actually npm workspaces inside the source tree, which
    # leave dangling symlinks behind. They can be safely removed, because their source is
    # bundled via webpack and thus not needed at run-time.
    rm -rf $out/lib/node_modules/@bitwarden/clients/node_modules/{@bitwarden,.bin}
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd bw --zsh <($out/bin/bw completion --shell zsh)
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    writableTmpDirAsHomeHook
    versionCheckHook
  ];

  makeCacheWritable = true;
  nodejs = nodejs_22;
  npmBuildScript = "build:oss:prod";
  npmDepsFetcherVersion = 2;
  npmFlags = [ "--legacy-peer-deps" ];

  npmRebuildFlags = [
    # we'll run npm rebuild manually later
    "--ignore-scripts"
  ];

  npmWorkspace = "apps/cli";
  versionCheckKeepEnvironment = [ "HOME" ];

  passthru = {
    inherit (finalAttrs) npmDeps;

    tests = {
      vaultwarden = nixosTests.vaultwarden.sqlite;
    };

    updateScript = nix-update-script {
      extraArgs = [
        "--version=stable"
        "--version-regex=^cli-v(.*)$"
      ];
    };
  };

  meta = {
    description = "Secure and free password manager for all of your devices";
    homepage = "https://bitwarden.com";
    changelog = "https://github.com/bitwarden/clients/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      xiaoxiangmoe
      dotlambda
      caverav
    ];

    mainProgram = "bw";
  };
})
