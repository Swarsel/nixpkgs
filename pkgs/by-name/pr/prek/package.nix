{
  lib,
  stdenv,
  fetchFromGitHub,
  git,
  installShellFiles,
  nix-update-script,
  python312,
  rustPlatform,
  uv,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "prek";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "j178";
    repo = "prek";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PAEmRQ5Vro83fkegOWsdY59U7WAQxBPSEalzxZV6K4o=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  cargoHash = "sha256-EmlR6Lmt5XR0uS/y3FqY5yGNeVBSdtLtEGH9jZLcP2o=";
  # many tests just do not work, as they require network access
  # best to disable all, as the upstream already tests everything
  doCheck = false;

  nativeCheckInputs = [
    git
    python312
    uv
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd prek \
      --bash <(COMPLETE=bash $out/bin/prek) \
      --fish <(COMPLETE=fish $out/bin/prek) \
      --zsh <(COMPLETE=zsh $out/bin/prek)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Better `pre-commit`, re-engineered in Rust ";
    homepage = "https://github.com/j178/prek";
    changelog = "https://github.com/j178/prek/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = [ lib.licenses.mit ];
    maintainers = [ lib.maintainers.thunze ];
    mainProgram = "prek";
  };
})
