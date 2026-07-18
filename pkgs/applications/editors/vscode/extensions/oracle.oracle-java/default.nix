{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension rec {
  mktplcRef = {
    version = "26.0.0";
    hash = "sha256-SfZMOiSuABXcYVi4CmxUUUIeAUmp6s45jjyy4HXoe24=";
    name = "oracle-java";
    publisher = "oracle";
  };

  meta = {
    description = "Java Platform Extension for Visual Studio Code";
    homepage = "https://github.com/oracle/javavscode/";
    changelog = "https://github.com/oracle/javavscode/releases/tag/v${mktplcRef.version}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.kiyotoko ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=oracle.oracle-java";
  };
}
