{
  lib,
  vscode-utils,
  wasm-language-tools,
}:

# The update script for the wasm-language-tools package itself updates this
# package too, so we disable nixpkgs-update for this package to avoid sometimes
# accidentally updating just this package by itself.

# nixpkgs-update: no auto update

vscode-utils.buildVscodeMarketplaceExtension {
  buildPhase = ''
    runHook preBuild
    ln -s ${wasm-language-tools}/bin bin
    runHook postBuild
  '';

  mktplcRef = {
    version = "1.21.0";
    hash = "sha256-r1gnq12O/tNx175/nmrQD3b7HVipVT0pEoLvg2HrWwI=";
    name = "wasm-language-tools";
    publisher = "gplane";
  };

  meta = {
    description = "Language support of WebAssembly";
    homepage = "https://github.com/g-plane/vscode-wasm";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ samestep ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=gplane.wasm-language-tools";
  };
}
