{
  lib,
  stdenv,
  fetchFromGitHub,
  gitMinimal,
  installShellFiles,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rumdl";
  version = "0.2.31";

  src = fetchFromGitHub {
    owner = "rvben";
    repo = "rumdl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sKL1Sn7ipv/5fGwblSTwwLnMEmmNqapBv4phS7sELFY=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  cargoHash = "sha256-Q9SQq5oyimRgxB+5FuRn73c00pqjeDDxuJ/klcvKck8=";

  nativeCheckInputs = [
    gitMinimal
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd rumdl \
      --bash <("$out/bin/rumdl" completions bash) \
      --fish <("$out/bin/rumdl" completions fish) \
      --zsh <("$out/bin/rumdl" completions zsh)
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;

  cargoBuildFlags = [
    "--bin=rumdl"
  ];

  cargoTestFlags = [
    "--lib"

    # Prefer the "smoke" profile over "ci" to exclude flaky tests: https://github.com/rvben/rumdl/pull/341
    "--profile"
    "smoke"
  ];

  useNextest = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Markdown linter and formatter";

    longDescription = ''
      rumdl is a high-performance Markdown linter and formatter
      that helps ensure consistency and best practices in your Markdown files.
    '';

    homepage = "https://github.com/rvben/rumdl";
    changelog = "https://github.com/rvben/rumdl/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      kachick
      hasnep
      faukah
    ];

    platforms = with lib.platforms; unix ++ windows;
    mainProgram = "rumdl";
  };
})
