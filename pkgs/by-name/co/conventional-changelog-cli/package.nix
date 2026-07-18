{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  makeBinaryWrapper,
  nix-update-script,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
  versionCheckHook,
}:
let
  pnpm = pnpm_10;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "conventional-changelog-cli";
  version = "7.2.1";

  src = fetchFromGitHub {
    owner = "conventional-changelog";
    repo = "conventional-changelog";
    tag = "conventional-changelog-v${finalAttrs.version}";
    hash = "sha256-1unB4/naGc/V1Fjc7Arn4DjnGvyCdicNFOofdgpvRUI=";
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
    makeBinaryWrapper
  ];

  buildPhase = ''
    runHook preBuild

    pnpm run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/conventional-changelog/
    mkdir $out/bin
    mv * $out/lib/node_modules/conventional-changelog/

    makeBinaryWrapper ${lib.getExe nodejs} $out/bin/conventional-changelog \
      --add-flags "$out/lib/node_modules/conventional-changelog/packages/conventional-changelog/dist/cli/index.js" \
      --set NODE_PATH "$out/lib/node_modules/conventional-changelog/node_modules"

    runHook postInstall
  '';

  postInstall = ''
    substituteInPlace $out/lib/node_modules/conventional-changelog/packages/*/package.json \
      --replace-warn '"exports": "./src/index.ts"' '"exports": "./dist/index.js"'
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-khAAFQeWUkALdkEdjW3tvCi5KiF9lN202yhLcj8ey1o=";
  };

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--use-github-releases"
      "--version-regex"
      "conventional-changelog-v(.*)"
    ];
  };

  meta = {
    description = "Generate a CHANGELOG from git metadata";
    homepage = "https://github.com/conventional-changelog/conventional-changelog";
    changelog = "https://github.com/conventional-changelog/conventional-changelog/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.isc;
    maintainers = [ ];
    mainProgram = "conventional-changelog";
  };
})
