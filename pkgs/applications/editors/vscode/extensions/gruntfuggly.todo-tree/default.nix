{
  lib,
  jq,
  moreutils,
  ripgrep,
  vscode-extension-update-script,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  strictDeps = true;

  nativeBuildInputs = [
    jq
    moreutils
  ];

  buildInputs = [ ripgrep ];

  postInstall = ''
    cd "$out/$installPrefix"
    jq '(.contributes.configuration[] | select(.title == "%todo-tree.configuration.regex%") | .properties."todo-tree.ripgrep.ripgrep".default) = $s' \
      --arg s "${lib.getExe ripgrep}" \
      package.json | sponge package.json
  '';

  __structuredAttrs = true;

  mktplcRef = {
    version = "0.0.226";
    hash = "sha256-Fj9cw+VJ2jkTGUclB1TLvURhzQsaryFQs/+f2RZOLHs=";
    name = "todo-tree";
    publisher = "Gruntfuggly";
  };

  passthru.updateScript = vscode-extension-update-script { };

  meta = {
    description = "Show TODO, FIXME, etc. comment tags in a tree view";
    homepage = "https://github.com/Gruntfuggly/todo-tree";
    changelog = "https://marketplace.visualstudio.com/items/Gruntfuggly.todo-tree/changelog";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      sandarukasa
    ];

    downloadPage = "https://marketplace.visualstudio.com/items?itemName=Gruntfuggly.todo-tree";
  };
}
