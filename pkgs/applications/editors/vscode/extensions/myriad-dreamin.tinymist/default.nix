{
  lib,
  jq,
  moreutils,
  tinymist,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  strictDeps = true;

  nativeBuildInputs = [
    jq
    moreutils
  ];

  buildInputs = [ tinymist ];

  postInstall = ''
    cd "$out/$installPrefix"
    jq '.contributes.configuration.properties."tinymist.serverPath".default = "${lib.getExe tinymist}"' package.json | sponge package.json
  '';

  __structuredAttrs = true;

  mktplcRef = {
    inherit (tinymist) version;
    hash = "sha256-FLWUeRPoqzHjwBrf0OOejaAVY+KBOpNBb9OJMdfLr04=";
    name = "tinymist";
    publisher = "myriad-dreamin";
  };

  meta = {
    description = "VSCode extension for providing an integration solution for Typst";
    homepage = "https://github.com/myriad-dreamin/tinymist";
    changelog = "https://marketplace.visualstudio.com/items/myriad-dreamin.tinymist/changelog";
    license = lib.licenses.asl20;
    maintainers = [ ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist";
  };
}
