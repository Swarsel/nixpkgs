{
  lib,
  fetchCrate,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fs-watcher-lsp";
  version = "0.1.0";

  src = fetchCrate {
    hash = "sha256-zahbi8RK8aDHcVOzIk5fCIh57+SjMGAVtUvtKhpMvF0=";
    crateName = "fs_watcher_lsp";
    version = finalAttrs.version;
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-w1i19IV/tjyl+W0NIjjbB0R9UpGrAUuK/yWbOZUKPUA=";
  doCheck = true;
  __structuredAttrs = true;
  buildNoDefaultFeatures = false;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Little file system watcher LSP to reload your editor";
    changelog = "https://codeberg.org/Zentropivity/fs_watcher_lsp/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      mit
      asl20
    ];

    maintainers = with lib.maintainers; [ landreussi ];
    mainProgram = "fs_watcher_lsp";
  };
})
