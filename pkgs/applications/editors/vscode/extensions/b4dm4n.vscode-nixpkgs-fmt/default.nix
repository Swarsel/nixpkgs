{
  lib,
  jq,
  moreutils,
  nixpkgs-fmt,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  nativeBuildInputs = [
    jq
    moreutils
  ];

  postInstall = ''
    cd "$out/$installPrefix"
    jq '.contributes.configuration.properties."nixpkgs-fmt.path".default = "${nixpkgs-fmt}/bin/nixpkgs-fmt"' package.json | sponge package.json
  '';

  mktplcRef = {
    version = "0.0.1";
    hash = "sha256-vz2kU36B1xkLci2QwLpl/SBEhfSWltIDJ1r7SorHcr8=";
    name = "nixpkgs-fmt";
    publisher = "B4dM4n";
  };

  meta = {
    license = lib.licenses.mit;
  };
}
