{
  lib,
  fetchFromGitHub,
  git,
  git-lfs,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  zlib,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "git-xet";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "huggingface";
    repo = "xet-core";
    tag = "git-xet-v${finalAttrs.version}";
    hash = "sha256-PmAJg7R5IBvDUsQGyDWzUz4bAFsR5ET1pOncpBGiHl4=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
    zlib
  ];

  cargoHash = "sha256-2f2lLSYcvllIKvyMlT5hphhkb0QY70wdTvncC1Lf4NI=";

  nativeCheckInputs = [
    git
    git-lfs
  ];

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  # Build only the git_xet package
  buildAndTestSubdir = "git_xet";
  versionCheckProgramArg = "--version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Git LFS plugin that uploads and downloads using the Xet protocol";
    homepage = "https://github.com/huggingface/xet-core/blob/main/git_xet/README.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      cybardev
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "git-xet";
  };
})
