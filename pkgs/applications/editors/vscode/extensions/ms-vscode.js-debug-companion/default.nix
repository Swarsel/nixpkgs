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
    pname = "vscode-js-debug-companion-vsix";
    version = "1.1.3";

    src = fetchFromGitHub {
      owner = "microsoft";
      repo = "vscode-js-debug-companion";
      tag = "v${finalAttrs.version}";
      hash = "sha256-+w6s6S1Vk99ABEJyQPEZXVPj0aNt6MvrD2nPGbxrsw0=";
    };

    strictDeps = true;

    nativeBuildInputs = [
      nodejs
      npmHooks.npmConfigHook
      vsce
    ];

    buildPhase = ''
      runHook preBuild
      vsce package
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp ./js-debug-companion-$version.vsix $out
      runHook postInstall
    '';

    name = "vscode-js-debug-companion-${finalAttrs.version}.vsix";

    npmDeps = fetchNpmDeps {
      inherit (finalAttrs) src;
      hash = "sha256-yirZRytdOYp7EMYIN6Yc7GC/9EFHONzarj+K/idj3pQ=";
      name = "${finalAttrs.pname}-npm-deps";
    };
  });
in
vscode-utils.buildVscodeExtension (finalAttrs: {
  inherit (finalAttrs.src) version;
  pname = "vscode-js-debug-companion";
  src = vsix;
  vscodeExtName = "js-debug-companion";
  vscodeExtPublisher = "ms-vscode";
  vscodeExtUniqueId = "${finalAttrs.vscodeExtPublisher}.${finalAttrs.vscodeExtName}";

  passthru = {
    updateScript = nix-update-script {
      attrPath = "vscode-extensions.ms-vscode.js-debug-companion.vsix";
    };

    vsix = finalAttrs.src;
  };

  meta = {
    description = "Companion extension to js-debug that provides capability for remote debugging";
    homepage = "https://github.com/microsoft/vscode-js-debug-companion";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xiaoxiangmoe ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=ms-vscode.js-debug-companion";
  };
})
