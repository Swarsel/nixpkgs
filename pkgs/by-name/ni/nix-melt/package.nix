{
  lib,
  fetchFromGitHub,
  installShellFiles,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nix-melt";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "nix-melt";
    rev = "v${finalAttrs.version}";
    hash = "sha256-jx7g9GOFAjOlJyNsGOUTLh2qWII9u0prOoBEvNPmdj8=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  cargoHash = "sha256-OTKK0d4yCTiK5GTw+LKagutRbok/zKqLkeOtInJ2L64=";

  env = {
    GEN_ARTIFACTS = "artifacts";
  };

  postInstall = ''
    installManPage artifacts/nix-melt.1
    installShellCompletion artifacts/nix-melt.{bash,fish} --zsh artifacts/_nix-melt
  '';

  meta = {
    description = "Ranger-like flake.lock viewer";
    homepage = "https://github.com/nix-community/nix-melt";
    changelog = "https://github.com/nix-community/nix-melt/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mpl20;

    maintainers = with lib.maintainers; [
      figsoda
      matthiasbeyer
    ];

    mainProgram = "nix-melt";
  };
})
