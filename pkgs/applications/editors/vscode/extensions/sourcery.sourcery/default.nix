{
  lib,
  stdenv,
  autoPatchelfHook,
  vscode-utils,
  zlib,
}:

let
  inherit (stdenv.hostPlatform) system;
in
vscode-utils.buildVscodeMarketplaceExtension (finalAttrs: {
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = [
    (lib.getLib stdenv.cc.cc)
    zlib
  ];

  mktplcRef = {
    version = "1.43.0";
    name = "sourcery";
    publisher = "sourcery";
  }
  // finalAttrs.passthru.platformTable.${system} or (throw "Unsupported platform ${system}");

  passthru.platformTable = {
    "aarch64-darwin" = {
      arch = "darwin-arm64";
      hash = "sha256-vMDB5zmdBNt3R5AkeuCYhxzW/rSGwM+wtU5K4v3ZU/U=";
    };

    "x86_64-linux" = {
      arch = "linux-x64";
      hash = "sha256-Oz4Buraof4yXIxGeKXIsDkvEQQ0Gzf/b5mdses1nHlo=";
    };
  };

  meta = {
    description = "VSCode extension for Sourcery, an AI-powered code review and pair programming tool for Python";
    homepage = "https://github.com/sourcery-ai/sourcery-vscode";
    changelog = "https://sourcery.ai/changelog/";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ tomasajt ];
    platforms = lib.attrNames finalAttrs.passthru.platformTable;
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=sourcery.sourcery";
  };
})
