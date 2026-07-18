{
  lib,
  clojure-lsp,
  jq,
  moreutils,
  vscode-extension-update-script,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  nativeBuildInputs = [
    jq
    moreutils
  ];

  postInstall = ''
    cd "$out/$installPrefix"
    jq '.contributes.configuration[0].properties."calva.clojureLspPath".default = "${clojure-lsp}/bin/clojure-lsp"' package.json | sponge package.json
  '';

  mktplcRef = {
    version = "2.0.593";
    hash = "sha256-/pPDghizzU/EulLyeFzmsufEwegR4ngo0rxW1Qnjock=";
    name = "calva";
    publisher = "betterthantomorrow";
  };

  passthru.updateScript = vscode-extension-update-script {
    extraArgs = [
      "--override-filename"
      "pkgs/applications/editors/vscode/extensions/betterthantomorrow.calva/default.nix"
    ];
  };

  meta.license = lib.licenses.mit;
}
