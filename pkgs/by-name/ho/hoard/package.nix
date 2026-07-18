{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hoard";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "Hyde46";
    repo = "hoard";
    rev = "v${finalAttrs.version}";
    hash = "sha256-c9iSbxkHwLOeATkO7kzTyLD0VAwZUzCvw5c4FyuR5/E=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-+XZL0a7/9Ic6cmym3ctwmGMu4xjGPCA2E7OrBj7Bfvw=";

  meta = {
    description = "CLI command organizer written in rust";
    homepage = "https://github.com/hyde46/hoard";
    changelog = "https://github.com/Hyde46/hoard/blob/${finalAttrs.src.rev}/CHANGES.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      builditluc
    ];

    mainProgram = "hoard";
  };
})
