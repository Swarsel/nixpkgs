{
  lib,
  jq,
  moreutils,
  shellcheck,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  nativeBuildInputs = [
    jq
    moreutils
  ];

  postInstall = ''
    cd "$out/$installPrefix"
    jq '.contributes.configuration.properties."shellcheck.executablePath".default = "${shellcheck}/bin/shellcheck"' package.json | sponge package.json
  '';

  mktplcRef = {
    version = "0.39.5";
    name = "shellcheck";
    publisher = "timonwong";
    sha256 = "sha256-8f9LGmNE8ilPYZmbJpmmAx9DkKJXbQzAia11rM3wTec=";
  };

  meta = {
    description = "Integrates ShellCheck into VS Code, a linter for Shell scripts";
    homepage = "https://github.com/vscode-shellcheck/vscode-shellcheck";
    license = lib.licenses.mit;
    maintainers = [ ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck";
  };
}
