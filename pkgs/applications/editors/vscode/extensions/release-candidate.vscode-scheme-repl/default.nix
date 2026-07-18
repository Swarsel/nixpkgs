{
  lib,
  chez,
  jq,
  moreutils,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  postInstall = ''
    cd "$out/$installPrefix"
    ${lib.getExe jq} '.contributes.configuration.properties."chezScheme.schemePath" = "${lib.getExe' chez "scheme"}"' package.json | ${lib.getExe' moreutils "sponge"} package.json
  '';

  mktplcRef = {
    version = "0.7.4";
    hash = "sha256-Pfy0aJXq8I53o5mG4dfzyqsyLQX0bs+phBgN46yU/Yw=";
    name = "vscode-scheme-repl";
    publisher = "release-candidate";
  };

  meta = {
    description = "Uses REPL for autocompletions and to evaluate expressions";
    homepage = "https://github.com/Release-Candidate/vscode-scheme-repl";
    license = lib.licenses.mit;
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=release-candidate.vscode-scheme-repl";
  };
}
