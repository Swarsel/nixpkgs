{
  lib,
  fetchFromGitHub,
  fetchNpmDeps,
  nix-update-script,
  nodejs,
  npmHooks,
  stdenvNoCC,
  vsce,
  vscode-utils,
}:

let
  vsix = stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "vscode-js-profile-table-vsix";
    version = "1.0.10";

    src = fetchFromGitHub {
      owner = "microsoft";
      repo = "vscode-js-profile-visualizer";
      tag = "v${finalAttrs.version}";
      hash = "sha256-NlL5o6PHkLY49Yo2bJOxYNs0IbO9x9DcMxGHEDKUOAk=";
    };

    patches = [ ./package-lock-json.patch ];
    strictDeps = true;

    nativeBuildInputs = [
      nodejs
      npmHooks.npmConfigHook
      vsce
    ];

    buildPhase = ''
      runHook preBuild
      node --run compile:core
      node --run compile:table
      cp ./LICENSE ./packages/vscode-js-profile-table/LICENSE
      (cd packages/vscode-js-profile-table && vsce package --no-dependencies)
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp ./packages/vscode-js-profile-table/vscode-js-profile-table-${finalAttrs.version}.vsix $out
      runHook postInstall
    '';

    makeCacheWritable = true;
    name = "vscode-js-profile-table-${finalAttrs.version}.vsix";

    npmDeps = fetchNpmDeps {
      inherit (finalAttrs) src patches;
      hash = "sha256-4Z5MjEM5WUKtISDjkpaEPR3jl1WWI7cbV4uTmgVoloU=";
      name = "${finalAttrs.pname}-npm-deps";
    };
  });
in
vscode-utils.buildVscodeExtension (finalAttrs: {
  inherit (finalAttrs.src) version;
  pname = "vscode-js-profile-table";
  src = vsix;
  vscodeExtName = "vscode-js-profile-table";
  vscodeExtPublisher = "ms-vscode";
  vscodeExtUniqueId = "${finalAttrs.vscodeExtPublisher}.${finalAttrs.vscodeExtName}";

  passthru = {
    updateScript = nix-update-script {
      attrPath = "vscode-extensions.ms-vscode.vscode-js-profile-table.vsix";
    };

    vsix = finalAttrs.src;
  };

  meta = {
    description = "Text visualizer for profiles taken from the JavaScript debugger";
    homepage = "https://github.com/microsoft/vscode-js-profile-visualizer";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xiaoxiangmoe ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=ms-vscode.vscode-js-profile-table";
  };
})
