{
  lib,
  jq,
  moreutils,
  terraform-ls,
  vscode-extension-update-script,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  postInstall = ''
    cd "$out/$installPrefix"
    ${lib.getExe jq} '.contributes.configuration[0].properties."terraform.languageServer.path".default = "${terraform-ls}/bin/terraform-ls"' package.json | ${lib.getExe' moreutils "sponge"} package.json
  '';

  mktplcRef = {
    version = "2.39.3";
    hash = "sha256-oU3kAhIsuadjyBvi+gJ6h19A3KueQYCZWLIN0ZUhoOE=";
    name = "terraform";
    publisher = "hashicorp";
  };

  passthru.updateScript = vscode-extension-update-script {
    extraArgs = [
      "--override-filename"
      "pkgs/applications/editors/vscode/extensions/hashicorp.terraform/default.nix"
    ];
  };

  meta = {
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.rhoriguchi ];
  };
}
