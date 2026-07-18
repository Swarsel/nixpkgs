{
  lib,
  fetchFromGitHub,
  installShellFiles,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "qrrs";
  version = "0.1.11";

  src = fetchFromGitHub {
    owner = "lenivaya";
    repo = "qrrs";
    rev = "v${finalAttrs.version}";
    hash = "sha256-lXfqKMJx9vtljQlYvbUAONFqMO3HKa4hx/29/YERw2U=";
  };

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-blBZOnrKdNfq010b6u1NmTLY3W9Q2BjQAVbW+oNbDlE=";

  postInstall = ''
    installManPage ./man/*.?


    installShellCompletion --cmd qrrs \
      --bash <(cat ./completions/qrrs.bash) \
      --fish <(cat ./completions/qrrs.fish) \
      --zsh <(cat ./completions/_qrrs)
  '';

  meta = {
    description = "CLI QR code generator and reader written in rust";
    homepage = "https://github.com/Lenivaya/qrrs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lenivaya ];
    mainProgram = "qrrs";
  };
})
