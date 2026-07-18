{
  lib,
  stdenv,
  fetchFromGitHub,
  git,
  installShellFiles,
  oniguruma,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "delta";
  version = "0.19.2";

  src = fetchFromGitHub {
    owner = "dandavison";
    repo = "delta";
    tag = finalAttrs.version;
    hash = "sha256-vW2mPAxlPXdwqyK/QhU/DOx6MD9u6DDVCDm0OEWm4AQ=";
  };

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ];

  buildInputs = [
    oniguruma
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    zlib
  ];

  cargoHash = "sha256-CC2ncgujdcn1CJxU16beCjfQ1HR2+f6D8qYbZULEm7g=";

  env = {
    RUSTONIG_SYSTEM_LIBONIG = true;
  };

  nativeCheckInputs = [ git ];

  checkFlags = lib.optionals stdenv.hostPlatform.isDarwin [
    # This test tries to read /etc/passwd, which fails with the sandbox
    # enabled on Darwin
    "--skip=test_diff_real_files"
  ];

  postInstall = ''
    installShellCompletion --cmd delta \
      --bash <($out/bin/delta --generate-completion bash) \
      --fish <($out/bin/delta --generate-completion fish) \
      --zsh <($out/bin/delta --generate-completion zsh)
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  # test_env_parsing_with_pager_set_to_bat sets environment variables,
  # which can be flaky with multiple threads:
  # https://github.com/dandavison/delta/issues/1660
  dontUseCargoParallelTests = true;

  meta = {
    description = "Syntax-highlighting pager for git";
    homepage = "https://github.com/dandavison/delta";
    changelog = "https://github.com/dandavison/delta/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      zowoq
      SuperSandro2000
    ];

    mainProgram = "delta";
  };
})
