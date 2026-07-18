{
  lib,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rfc-reader";
  version = "0.11.2";

  src = fetchFromGitHub {
    owner = "ozan2003";
    repo = "rfc_reader";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Hm8BVIMxRlyiVptvuS8vk2eO3hHboj5CRefWcMEhzvs=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-ro0BVMbShxo/EsPBOCBOgYDsOkDnxpyTZlk2eAJ2IWA=";
  __structuredAttrs = true;

  passthru.tests.version = testers.testVersion {
    # The version command triggers logging unconditionally, have to create a temp directory
    command = "HOME=$(mktemp -d) rfc_reader --version";
    package = finalAttrs.finalPackage;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "RFC viewer with TUI";
    homepage = "https://github.com/ozan2003/rfc_reader";
    changelog = "https://github.com/ozan2003/rfc_reader/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ frantathefranta ];
    mainProgram = "rfc_reader";
  };
})
