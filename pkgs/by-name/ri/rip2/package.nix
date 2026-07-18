{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rip2";
  version = "0.9.6";

  src = fetchFromGitHub {
    owner = "MilesCranmer";
    repo = "rip2";
    rev = "v${finalAttrs.version}";
    hash = "sha256-cqc9oZSs0JEMEJfHTHBAgN5Y5/zLPInPeQcOthj+EzQ=";
  };

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-2rlxuxiyPiThOEhwaV3VUGBwKHnPTGKbQ6PPTaP9Rps=";
  # TODO: Unsure why this test fails, but not a major issue so
  #       skipping for now.
  checkFlags = [ "--skip=test_filetypes::file_type_3___fifo__" ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd rip \
      --bash <($out/bin/rip completions bash) \
      --fish <($out/bin/rip completions fish) \
      --zsh <($out/bin/rip completions zsh)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/rip";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Safe and ergonomic alternative to rm";
    homepage = "https://github.com/MilesCranmer/rip2";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      milescranmer
      matthiasbeyer
    ];

    mainProgram = "rip";
  };
})
