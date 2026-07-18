{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  esbuild,
  nix-update-script,
  versionCheckHook,
  vscode-extensions,
}:
let
  inherit (vscode-extensions.chenglou92.rescript-vscode) rescript-editor-analysis;
  platformDir =
    if stdenv.hostPlatform.isLinux then
      "linux"
    else if stdenv.hostPlatform.isDarwin then
      "darwin"
    else if stdenv.hostPlatform.isFreeBSD then
      "freebsd"
    else if stdenv.hostPlatform.isWindows then
      "win32"
    else
      throw "Unsupported system: ${stdenv.system}";
in
buildNpmPackage (finalAttrs: {
  # These have the same source, and must be the same version.
  inherit (rescript-editor-analysis) src version;
  pname = "rescript-language-server";
  strictDeps = true;
  nativeBuildInputs = [ esbuild ];
  npmDepsHash = "sha256-BUR/gln9yyKGa05FvxOF6vIcCz8BCQWGr/fzfmOPdj0=";

  # Tries to do funny things (install all packages for the entire repo) if you don't override it. This is just a copy paste
  # from the package.json.
  buildPhase = ''
    runHook preBuild

    # https://github.com/rescript-lang/rescript-vscode/blob/1.72.0/package.json#L286
    esbuild src/cli.ts --bundle --sourcemap --outfile=out/cli.js --format=cjs --platform=node --loader:.node=file --minify

    runHook postBuild
  '';

  postInstall = ''
    DIR="$out/lib/node_modules/@rescript/language-server/analysis_binaries/${platformDir}"

    mkdir -p "$DIR"
    ln -s ${lib.getExe rescript-editor-analysis} "$DIR"/rescript-editor-analysis
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  npmDepsFetcherVersion = 2;
  sourceRoot = "${finalAttrs.src.name}/server";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "([0-9]+\\.[0-9]+\\.[0-9]+)"
    ];
  };

  meta = {
    description = "ReScript Language Server";
    homepage = "https://github.com/rescript-lang/rescript-vscode/tree/${finalAttrs.version}/server";
    changelog = "https://github.com/rescript-lang/rescript-vscode/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    # https://github.com/rescript-lang/rescript-vscode/blob/1.62.0/CONTRIBUTING.md?plain=1#L186
    platforms = with lib.platforms; linux ++ darwin ++ windows ++ freebsd;
    mainProgram = "rescript-language-server";
  };
})
