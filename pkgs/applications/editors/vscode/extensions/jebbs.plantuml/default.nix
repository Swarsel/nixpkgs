{
  lib,
  jq,
  moreutils,
  plantuml,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  nativeBuildInputs = [
    jq
    moreutils
  ];

  postInstall = ''
    cd "$out/$installPrefix"
    jq '.contributes.configuration.properties."plantuml.java".default = "${plantuml}/bin/plantuml"' package.json | sponge package.json
  '';

  mktplcRef = {
    version = "2.18.1";
    hash = "sha256-o4FN/vUEK53ZLz5vAniUcnKDjWaKKH0oPZMbXVarDng=";
    name = "plantuml";
    publisher = "jebbs";
  };

  meta = {
    description = "Visual Studio Code extension for supporting Rich PlantUML";
    homepage = "https://github.com/qjebbs/vscode-plantuml";
    changelog = "https://marketplace.visualstudio.com/items/jebbs.plantuml/changelog";
    license = lib.licenses.mit;
    maintainers = [ ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=jebbs.plantuml";
  };
}
