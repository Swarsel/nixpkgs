{ lib, vscode-utils }:

vscode-utils.buildVscodeMarketplaceExtension (finalAttrs: {
  mktplcRef = {
    version = "0.0.19";
    hash = "sha256-OfPSh0SapT+YOfi0cz3ep8hEhgCTHpjs1FfmgAyjN58=";
    name = "fluent-icons";
    publisher = "miguelsolorio";
  };

  meta = {
    description = "Fluent product icons for Visual Studio Code";
    homepage = "https://github.com/miguelsolorio/vscode-fluent-icons";
    changelog = "https://github.com/miguelsolorio/vscode-fluent-icons/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.iamanaws ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=miguelsolorio.fluent-icons";
  };
})
