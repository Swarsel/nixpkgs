{
  lib,
  fetchFromGitHub,
  # nativeBuildInputs
  installShellFiles,
  rustPlatform,
  scdoc,
  # nativeInstallCheckInputs
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mastermind";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "mahyarmirrashed";
    repo = "mastermind";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WWM3OnPJm5BvD2l5KnKrlfKqvMcyrpStcji1joq28hg=";
  };

  nativeBuildInputs = [
    installShellFiles
    scdoc
  ];

  cargoHash = "sha256-N6zjgcaJRwRdmvIXzwFeiW1YCpRV6P2P7uj7D2EK0IQ=";

  postInstall = ''
    scdoc < doc/mastermind.6.scd > mastermind.6
    installManPage mastermind.6
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "A game of cunning and logic";
    homepage = "https://github.com/mahyarmirrashed/mastermind";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mahyarmirrashed ];
    mainProgram = "mastermind";
  };
})
