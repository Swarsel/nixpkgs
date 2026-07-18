{
  lib,
  stdenv,
  jq,
  moreutils,
  typos-lsp,
  vscode-extension-update-script,
  vscode-utils,
}:
let
  inherit (stdenv.hostPlatform) system;

  extInfo =
    {
      aarch64-darwin = {
        arch = "darwin-arm64";
        hash = "sha256-rHgMl71YCs9ea0nFnx+E2U8isL4zQzIvvE9tgxM7IiA=";
      };

      aarch64-linux = {
        arch = "linux-arm64";
        hash = "sha256-Z3cRojI4mCCS2t3aLojgImULQOobq5liDwoeHuzKEhY=";
      };

      x86_64-linux = {
        arch = "linux-x64";
        hash = "sha256-jAQJh1JqomJDUFeb2N452ICo0azFelT8vHvEsBqXi8w=";
      };
    }
    .${system} or (throw "Unsupported system: ${system}");
in
vscode-utils.buildVscodeMarketplaceExtension (finalAttrs: {
  nativeBuildInputs = [
    jq
    moreutils
  ];

  buildInputs = [ typos-lsp ];

  postInstall = ''
    cd "$out/$installPrefix"
    jq '.contributes.configuration.properties."typos.path".default = "${lib.getExe typos-lsp}"' package.json | sponge package.json
  '';

  mktplcRef = {
    inherit (extInfo) hash arch;
    # Please update the corresponding binary (typos-lsp)
    # when updating this extension.
    # See pkgs/by-name/ty/typos-lsp/package.nix
    version = "0.1.51";
    name = "typos-vscode";
    publisher = "tekumara";
  };

  passthru.updateScript = vscode-extension-update-script { };

  meta = {
    description = "VSCode extension for providing a low false-positive source code spell checker";
    homepage = "https://github.com/tekumara/typos-lsp";
    changelog = "https://github.com/tekumara/typos-lsp/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];

    platforms = [
      "aarch64-linux"
      "aarch64-darwin"
      "x86_64-linux"
    ];

    downloadPage = "https://marketplace.visualstudio.com/items?itemName=tekumara.typos-vscode";
  };
})
