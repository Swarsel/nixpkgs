{
  lib,
  stdenv,
  fetchFromGitHub,
  clang_20,
  fetchNpmDeps,
  libsecret,
  nix-update-script,
  nodejs-slim,
  npmHooks,
  pkg-config,
  vscode-utils,
}:

let
  vsix = stdenv.mkDerivation (finalAttrs: {
    pname = "prettier-vscode-vsix";
    version = "12.4.0";

    src = fetchFromGitHub {
      owner = "prettier";
      repo = "prettier-vscode";
      tag = "v${finalAttrs.version}";
      hash = "sha256-N++WB0CvqYQTRg3SQFf9QJrwSJXtUd7z/kvWXQqOSC4=";
    };

    strictDeps = true;

    nativeBuildInputs = [
      nodejs-slim
      nodejs-slim.npm
      nodejs-slim.python
      npmHooks.npmConfigHook
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      pkg-config
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      clang_20 # clang_21 breaks @vscode/vsce's optional dependency keytar
    ];

    buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
      libsecret
    ];

    env.PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";

    buildPhase = ''
      runHook preBuild

      node --run compile
      npx @vscode/vsce package --out $out

      runHook postBuild
    '';

    name = "prettier-vscode-${finalAttrs.version}.vsix";

    npmDeps = fetchNpmDeps {
      inherit (finalAttrs) src;
      hash = "sha256-vktxhQA2a+D9Nr4vhbmGCnNdGzt0U89K50g0SgiV5SE=";
      name = "${finalAttrs.pname}-npm-deps";
    };
  });
in
vscode-utils.buildVscodeExtension (finalAttrs: {
  inherit (finalAttrs.src) version;
  pname = "prettier-vscode";
  src = vsix;
  vscodeExtName = "prettier-vscode";
  vscodeExtPublisher = "prettier";
  vscodeExtUniqueId = "${finalAttrs.vscodeExtPublisher}.${finalAttrs.vscodeExtName}";

  passthru = {
    updateScript = nix-update-script {
      attrPath = "vscode-extensions.prettier.prettier-vscode.vsix";
    };

    vsix = finalAttrs.src;
  };

  meta = {
    description = "Visual Studio Code extension for Prettier";
    homepage = "https://github.com/prettier/prettier-vscode";
    changelog = "https://marketplace.visualstudio.com/items/Prettier.prettier-vscode/changelog";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xiaoxiangmoe ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=Prettier.prettier-vscode";
  };
})
