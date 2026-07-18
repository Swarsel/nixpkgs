{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  typescript,
}:

buildNpmPackage (finalAttrs: {
  pname = "vscode-json-languageserver";
  version = "1.3.4";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "vscode";
    tag = "1.101.2";
    hash = "sha256-wdI6VlJ4WoSNnwgkb6dkVYcq/P/yzflv5mE9PuYBVx4=";
  };

  nativeBuildInputs = [ typescript ];
  npmDepsHash = "sha256-akQukdYTe6um4xo+7T3wHxx+WrXfKYl5a1qwmqX72HQ=";

  buildPhase = ''
    runHook preBuild
    tsc -p .
    runHook postBuild
  '';

  postInstall = ''
    ln -s $out/bin/vscode-json-languageserver $out/bin/vscode-json-language-server
  '';

  dontNpmBuild = true;
  sourceRoot = "${finalAttrs.src.name}/extensions/json-language-features/server";

  meta = {
    description = "JSON language server";
    homepage = "https://github.com/microsoft/vscode/tree/${finalAttrs.src.tag}/extensions/json-language-features/server";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ryota2357 ];
    mainProgram = "vscode-json-languageserver";
  };
})
