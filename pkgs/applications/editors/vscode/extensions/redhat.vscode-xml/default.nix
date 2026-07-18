{
  lib,
  stdenvNoCC,
  vscode-extension-update-script,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef =
    let
      sources = {
        "aarch64-darwin" = {
          arch = "darwin-arm64";
          hash = "sha256-XYdwVoDqK+88ZYUm6APyamFNx6XlYjy0R4CIhSMuRmU=";
        };

        "x86_64-linux" = {
          arch = "linux-x64";
          hash = "sha256-cP/oFn19CZ/G3kjdHNZGqXvoDE1qUtg6xrg/2MO14Lo=";
        };
      };
    in
    {
      version = "0.29.3";
      name = "vscode-xml";
      publisher = "redhat";
    }
    // sources.${stdenvNoCC.hostPlatform.system} or { };

  passthru.updateScript = vscode-extension-update-script {
    extraArgs = [
      "--override-filename"
      "pkgs/applications/editors/vscode/extensions/redhat.vscode-xml/default.nix"
    ];
  };

  meta = {
    license = lib.licenses.epl20;

    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
  };
}
