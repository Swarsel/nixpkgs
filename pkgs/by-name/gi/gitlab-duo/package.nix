{
  lib,
  stdenv,
  fetchFromGitLab,
  buildNpmPackage,
  bun,
  concurrently,
  nodejs_22,
  patch-package,
  ripgrep,
  versionCheckHook,
}:
buildNpmPackage (finalAttrs: {
  pname = "gitlab-duo";
  version = "8.89.0";

  src = fetchFromGitLab {
    owner = "editor-extensions";
    repo = "gitlab-lsp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AiC0xxk8d/2rvRGm31vWqRuJ7nzMrITTGabv7v1LpOA=";
    group = "gitlab-org";
  };

  patches = [
    # HACK https://github.com/NixOS/nixpkgs/issues/408720
    # Fix packages locked but without hash, or even missing
    ./missing-hashes.patch
  ];

  nativeBuildInputs = [
    bun
    concurrently
    patch-package
  ];

  npmDepsHash = "sha256-U/dwfYZqy/1CM+Emz1w44mAzY24Z8vKWBXSzSqeVmnY=";
  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "true";
  env.PUPPETEER_SKIP_DOWNLOAD = "true";
  env.SKIP_RIPGREP_BUNDLE = 1;
  env.SUPPORTED_TARGETS = "bun-${stdenv.targetPlatform.node.platform}-${stdenv.targetPlatform.node.arch}";
  env.TARGET = "${stdenv.targetPlatform.node.platform}-${stdenv.targetPlatform.node.arch}";

  postConfigure = ''
    patchShebangs --build ./packages/cli/scripts
    npmBuildScript=build:bundle runHook npmBuildHook
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 packages/cli/bin/duo-$TARGET $out/bin/duo

    wrapProgram $out/bin/duo \
      --prefix PATH : ${lib.getExe ripgrep}

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  # DOCS https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp#node-version
  nodejs = nodejs_22;
  npmBuildScript = "build:binary";
  npmFlags = [ "--install-links" ];
  npmRebuildFlags = [ "--ignore-scripts" ];
  npmWorkspace = "@gitlab/duo-cli";
  versionCheckProgramArg = "--version";
  passthru.updateScript = ./update.sh;

  meta = {
    description = "CLI for GitLab AI assistant";
    homepage = "https://about.gitlab.com/gitlab-duo/";
    changelog = "https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp/-/blob/main/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ afontaine ];
    mainProgram = "duo";
    downloadPage = "https://gitlab.com/gitlab-org/editor-extensions/gitlab-lsp";
  };
})
