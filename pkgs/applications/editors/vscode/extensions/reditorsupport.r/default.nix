{
  lib,
  R,
  jq,
  moreutils,
  rPackages,
  radian,
  vscode-utils,
  languageserver ? rPackages.languageserver,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  nativeBuildInputs = [
    jq
    moreutils
  ];

  postInstall = ''
    cd "$out/$installPrefix"
    jq '.contributes.configuration.properties."r.rpath.mac".default = "${lib.getExe' R "R"}"' package.json | sponge package.json
    jq '.contributes.configuration.properties."r.rpath.linux".default = "${lib.getExe' R "R"}"' package.json | sponge package.json
    jq '.contributes.configuration.properties."r.rterm.mac".default = "${lib.getExe radian}"' package.json | sponge package.json
    jq '.contributes.configuration.properties."r.rterm.linux".default = "${lib.getExe radian}"' package.json | sponge package.json
    jq '.contributes.configuration.properties."r.libPaths".default = [ "${languageserver}/library" ]' package.json | sponge package.json
  '';

  mktplcRef = {
    version = "2.8.8";
    hash = "sha256-mt2bes7aHcAHLMngSLW/zI3kSIzNKALqX+g0UXo84uI=";
    name = "r";
    publisher = "reditorsupport";
  };

  meta = {
    description = "Visual Studio Code extension for the R programming language";
    homepage = "https://github.com/REditorSupport/vscode-R";
    changelog = "https://marketplace.visualstudio.com/items/REditorSupport.r/changelog";
    license = lib.licenses.mit;

    maintainers = [
      lib.maintainers.pandapip1
      lib.maintainers.ivyfanchiang
    ];

    downloadPage = "https://marketplace.visualstudio.com/items?itemName=REditorSupport.r";
  };
}
