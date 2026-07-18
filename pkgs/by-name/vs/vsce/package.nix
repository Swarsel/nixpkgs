{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  clang_20,
  libsecret,
  nix-update-script,
  nodejs-slim,
  pkg-config,
  versionCheckHook,
}:

buildNpmPackage (finalAttrs: {
  pname = "vsce";
  version = "3.9.2";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "vscode-vsce";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DjPRSFXkw+MXDGjpWJGdp1bfptFdQEs5Djft2WyYK70=";
  };

  postPatch = ''
    substituteInPlace package.json --replace-fail '"version": "0.0.0"' '"version": "${finalAttrs.version}"'
  '';

  nativeBuildInputs = [
    pkg-config
    nodejs-slim.python
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ clang_20 ]; # clang_21 breaks @vscode/vsce's optional dependency keytar

  buildInputs = [ libsecret ];
  npmDepsHash = "sha256-U5FTBunSvHDl1lCMNcTuPrVZw6YTbT3LCJfbc6E2Sys=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  makeCacheWritable = true;

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "^v(\\d+\\.\\d+\\.\\d+)$"
      ];
    };
  };

  meta = {
    description = "Visual Studio Code Extension Manager";
    homepage = "https://github.com/microsoft/vscode-vsce";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      xiaoxiangmoe
    ];

    mainProgram = "vsce";
  };
})
