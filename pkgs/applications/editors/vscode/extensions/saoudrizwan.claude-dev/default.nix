{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "3.89.2";
    hash = "sha256-lDt/xn1PFs0UDg0rOOun8Bl/FTXSjvQ//ETkoHFypAM=";
    name = "claude-dev";
    publisher = "saoudrizwan";
  };

  meta = {
    description = "Cline - autonomous coding agent VSCode extension, capable of creating/editing files, executing commands, using the browser, and more with your permission every step of the way";
    homepage = "https://github.com/cline/cline";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.matteopacini ];
    downloadPage = "https://github.com/cline/cline";
  };
}
