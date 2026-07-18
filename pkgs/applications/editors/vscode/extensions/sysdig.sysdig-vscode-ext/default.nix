{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "0.2.17";
    hash = "sha256-8qYDp6IcUvlFdCPmMozHVocsgGqK8b2+tve1wBO3bhU=";
    name = "sysdig-vscode-ext";
    publisher = "sysdig";
  };

  meta = {
    description = "Scan your VS Code projects with Sysdig to investigate misconfigurations in IaC files or track vulnerabilities";
    homepage = "https://github.com/sysdiglabs/vscode-extension";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ tembleking ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=sysdig.sysdig-vscode-ext";
  };
}
