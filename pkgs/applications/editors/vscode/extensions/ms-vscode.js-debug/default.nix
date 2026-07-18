{
  lib,
  stdenv,
  fetchFromGitHub,
  cctools,
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
    pname = "vscode-js-debug-vsix";
    version = "1.117.0";

    src = fetchFromGitHub {
      owner = "microsoft";
      repo = "vscode-js-debug";
      tag = "v${finalAttrs.version}";
      hash = "sha256-1Mj7nfX5iVO0hhydCV/VbqN1x77WFEzG6/ahk1kN1fw=";
    };

    postPatch = ''
      substituteInPlace package.json \
        --replace-fail "playwright install chromium --with-deps --only-shell" "echo playwright install chromium --with-deps --only-shell"
    '';

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
      cctools.libtool
      clang_20 # clang_21 breaks @vscode/vsce's optional dependency keytar
    ];

    buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
      libsecret
    ];

    buildPhase = ''
      runHook preBuild
      node --run compile -- package:hoist
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp ./js-debug.vsix $out
      runHook postInstall
    '';

    makeCacheWritable = true;
    name = "vscode-js-debug-${finalAttrs.version}.vsix";

    npmDeps = fetchNpmDeps {
      inherit (finalAttrs) src;
      hash = "sha256-uTtA5XjHfuI2e9IuNAYfDNKZE8c/wa+CWqAsmd/M3Xk=";
      name = "${finalAttrs.pname}-npm-deps";
    };
  });
in
vscode-utils.buildVscodeExtension (finalAttrs: {
  inherit (finalAttrs.src) version;
  pname = "vscode-js-debug";
  src = vsix;
  vscodeExtName = "js-debug";
  vscodeExtPublisher = "ms-vscode";
  vscodeExtUniqueId = "${finalAttrs.vscodeExtPublisher}.${finalAttrs.vscodeExtName}";

  passthru = {
    updateScript = nix-update-script {
      attrPath = "vscode-extensions.ms-vscode.js-debug.vsix";
    };

    vsix = finalAttrs.src;
  };

  meta = {
    description = "An extension for debugging Node.js programs and Chrome";
    homepage = "https://github.com/microsoft/vscode-js-debug";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xiaoxiangmoe ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=ms-vscode.js-debug";
  };
})
