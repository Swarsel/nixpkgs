{
  lib,
  fetchFromGitHub,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kittycad-kcl-lsp";
  version = "0.1.71";

  src = fetchFromGitHub {
    owner = "KittyCAD";
    repo = "kcl-lsp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IQfR2B9HyZXEDKcp5J7466SRbq2qWS+eodtTKkgJprM=";
  };

  nativeBuildInputs = [ pkg-config ];
  cargoHash = "sha256-OlAy/WqoLRwkk1x4dOXE8MzBzeLyofQDVv81aR/sIMQ=";

  meta = {
    description = "KittyCAD KCL language server";
    homepage = "https://github.com/KittyCAD/kcl-lsp";
    changelog = "https://github.com/KittyCAD/kcl-lsp/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jljox ];
    mainProgram = "kittycad-kcl-lsp";
  };
})
