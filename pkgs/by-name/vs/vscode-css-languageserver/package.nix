{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  makeBinaryWrapper,
  nodejs,
  typescript,
}:

buildNpmPackage (finalAttrs: {
  pname = "vscode-css-languageserver";
  version = "1.105.0";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "vscode";
    tag = finalAttrs.version;
    hash = "sha256-t3S8PHxuwz1DxJ+FPJkRCyaPm4tPW/fHKj3aiIaTuls=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
    typescript
  ];

  npmDepsHash = "sha256-duYwm1Hf9oLyu0gapdEGbXqdwFV4svkX2tGhvyoZ5Lo=";

  buildPhase = ''
    runHook preBuild
    tsc -p .
    runHook postBuild
  '';

  postInstall = ''
    makeBinaryWrapper ${nodejs}/bin/node $out/bin/vscode-css-languageserver \
      --add-flags $out/lib/node_modules/vscode-css-languageserver/out/node/cssServerMain.js
    ln -s $out/bin/vscode-css-languageserver $out/bin/vscode-css-language-server
  '';

  dontNpmBuild = true;
  sourceRoot = "${finalAttrs.src.name}/extensions/css-language-features/server";

  meta = {
    description = "CSS language server";
    homepage = "https://github.com/microsoft/vscode/tree/${finalAttrs.src.tag}/extensions/css-language-features/server";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ryota2357 ];
    mainProgram = "vscode-css-languageserver";
  };
})
