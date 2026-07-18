{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tombi";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "tombi-toml";
    repo = "tombi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0ACGYRexG39FG5DzcayEUdsF1JvSPbzJq4m9I1ZWnSI=";
  };

  postPatch = ''
    substituteInPlace Cargo.toml \
      --replace-fail 'version = "0.0.0-dev"' 'version = "${finalAttrs.version}"'
  '';

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-IgtFNjp8fql01KGCR6h4+QtEm3AxJxsq900ZEwhRWhg=";
  # Tests relies on the presence of network
  doCheck = false;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd tombi \
      --bash <($out/bin/tombi completion bash) \
      --fish <($out/bin/tombi completion fish) \
      --zsh <($out/bin/tombi completion zsh)
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __structuredAttrs = true;

  cargoBuildFlags = [
    "--package"
    "tombi-cli"
  ];

  meta = {
    description = "TOML Formatter / Linter / Language Server";
    homepage = "https://github.com/tombi-toml/tombi";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      faukah
      psibi
      yvnth
    ];

    mainProgram = "tombi";
  };
})
