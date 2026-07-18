{
  lib,
  stdenv,
  autoPatchelfHook,
  stdenvNoCC,
  vscode-extension-update-script,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  strictDeps = true;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  __structuredAttrs = true;

  mktplcRef =
    let
      sources = {
        "aarch64-darwin" = {
          arch = "darwin-arm64";
          hash = "sha256-YBapB9XZ1/fUOflFDxZGT9rnPTumHQR/PfmyISHAAkY=";
        };

        "aarch64-linux" = {
          arch = "linux-arm64";
          hash = "sha256-rgeNJbl6G2yKAWYW7NarQwVLmd3oZ4YTOVeCUat6ZqQ=";
        };

        "x86_64-linux" = {
          arch = "linux-x64";
          hash = "sha256-htZGjy7ZnQLGZUncokGaGHyLpvPM5jzWUvCdnfN1vbM=";
        };
      };
    in
    {
      version = "0.30.0";
      name = "visualjj";
      publisher = "visualjj";
    }
    // sources.${stdenvNoCC.hostPlatform.system}
      or (throw "Unsupported system ${stdenvNoCC.hostPlatform.system}");

  passthru.updateScript = vscode-extension-update-script { };

  meta = {
    description = "Jujutsu version control integration, for simpler Git workflow";
    homepage = "https://www.visualjj.com";
    changelog = "https://marketplace.visualstudio.com/items/visualjj.visualjj/changelog";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ sandarukasa ];

    platforms = [
      "aarch64-linux"
      "aarch64-darwin"
      "x86_64-linux"
    ];

    downloadPage = "https://marketplace.visualstudio.com/items?itemName=visualjj.visualjj";
  };
}
