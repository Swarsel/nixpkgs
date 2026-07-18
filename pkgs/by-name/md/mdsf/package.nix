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
  pname = "mdsf";
  version = "0.11.1";

  src = fetchFromGitHub {
    owner = "hougesen";
    repo = "mdsf";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UfLgrukVYqkUKBI7CNLIkANO1md6ArrbSIh+f0F3bek=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  cargoHash = "sha256-dohbFCxoPPXZa6mKkDNmdkqH3T52hHiRTDgQJTJHfYU=";
  # many tests fail for various reasons of which most depend on the build sandbox
  doCheck = false;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd mdsf \
      --bash <($out/bin/mdsf completions bash) \
      --zsh <($out/bin/mdsf completions zsh) \
      --fish <($out/bin/mdsf completions fish) \
      --nushell <($out/bin/mdsf completions nushell)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Format markdown code blocks using your favorite tools";
    homepage = "https://github.com/hougesen/mdsf";
    changelog = "https://github.com/hougesen/mdsf/releases";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ luftmensch-luftmensch ];
    mainProgram = "mdsf";
  };
})
