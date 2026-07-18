{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "lintspec";
  version = "0.18.0";

  src = fetchFromGitHub {
    owner = "beeb";
    repo = "lintspec";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CPyMP/UGP2PJ9tjNT0Ytj7jnA4BFBIXw3ZT1NHfKGAA=";
  };

  strictDeps = true;
  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-WMe9/7rk6tkpWQ7hezHTAoyvCE6Oo66RAfhz7NpT7JM=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd lintspec \
      --bash <($out/bin/lintspec completions -s bash) \
      --fish <($out/bin/lintspec completions -s fish) \
      --zsh <($out/bin/lintspec completions -s zsh)
  '';

  __structuredAttrs = true;

  cargoBuildFlags = [
    "--package"
    "lintspec"
  ];

  meta = {
    description = "Blazingly fast linter for NatSpec comments in Solidity code";
    homepage = "https://github.com/beeb/lintspec";
    changelog = "https://github.com/beeb/lintspec/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      mit
      asl20
    ];

    maintainers = with lib.maintainers; [ beeb ];
    mainProgram = "lintspec";
  };
})
