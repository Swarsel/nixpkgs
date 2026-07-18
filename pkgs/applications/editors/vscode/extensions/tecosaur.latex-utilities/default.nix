{
  lib,
  jq,
  moreutils,
  texlivePackages,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension (finalAttrs: {
  nativeBuildInputs = [
    jq
    moreutils
  ];

  buildInputs = [ texlivePackages.texcount ];

  postInstall = ''
    cd "$out/$installPrefix"
    echo -n ${finalAttrs.version} > VERSION
    jq '.contributes.configuration.properties."latex-utilities.countWord.path".default = "${texlivePackages.texcount}/bin/texcount"' package.json | sponge package.json
  '';

  mktplcRef = {
    version = "0.4.14";
    hash = "sha256-GsbHzFcN56UbcaqFN9s+6u/KjUBn8tmks2ihK0pg3Ds=";
    name = "latex-utilities";
    publisher = "tecosaur";
  };

  meta = {
    description = "Add-on to the Visual Studio Code extension LaTeX Workshop";
    homepage = "https://github.com/tecosaur/LaTeX-Utilities";
    changelog = "https://marketplace.visualstudio.com/items/tecosaur.latex-utilities/changelog";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jeancaspar ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=tecosaur.latex-utilities";
  };
})
