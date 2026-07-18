{
  lib,
  asciidoctor,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  patches = [
    ./commands-abspath.patch
  ];

  postPatch = ''
    substituteInPlace package.json \
        --replace-fail "@ASCIIDOCTOR_PDF_BIN@" \
                       "${asciidoctor}/bin/asciidoctor-pdf"
  '';

  mktplcRef = {
    version = "3.4.5";
    hash = "sha256-X7njFSqfb45l6ZTr7GDS3At6DMHyvBT41JoghOeVjwI=";
    name = "asciidoctor-vscode";
    publisher = "asciidoctor";
  };

  meta = {
    license = lib.licenses.mit;
  };
}
