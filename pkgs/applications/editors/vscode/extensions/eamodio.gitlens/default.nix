{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  nix-update-script,
  nodejs,
  pkgs,
  pnpmConfigHook,
  pnpm_10,
  vscode-utils,
}:

let
  pnpm = pnpm_10;

  vsix = stdenv.mkDerivation (finalAttrs: {
    pname = "gitlens-vsix";
    version = "17.11.1";

    src = fetchFromGitHub {
      owner = "gitkraken";
      repo = "vscode-gitlens";
      tag = "v${finalAttrs.version}";
      hash = "sha256-BN6qgPYhZ+FuYnwmV0S3y2vOR4ZLC+VGWuEEPqfOqi4=";
    };

    postPatch = ''
      substituteInPlace scripts/generateLicenses.mjs --replace-fail 'https://raw.githubusercontent.com/microsoft/vscode/refs/heads/main/LICENSE.txt' '${pkgs.vscode-json-languageserver.src}/LICENSE.txt'
      substituteInPlace package.json --replace-fail '"vscode:prepublish": "pnpm run bundle"' '"vscode:prepublish": "pnpm run bundle:turbo"'
    '';

    strictDeps = true;

    nativeBuildInputs = [
      nodejs
      pnpmConfigHook
      pnpm
    ];

    env.npm_config_manage_package_manager_versions = "false";

    # Error: spawn /build/source/node_modules/.pnpm/sass-embedded-linux-x64@1.77.8/node_modules/sass-embedded-linux-x64/dart-sass/src/dart ENOENT
    # Remove both node_modules/.pnpm/sass-embedded and node_modules/.pnpm/sass-embedded-linux-x64
    preBuild = ''
      rm -r node_modules/.pnpm/sass-embedded*
    '';

    buildPhase = ''
      runHook preBuild

      node --run package

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp ./gitlens-$version.vsix $out

      runHook postInstall
    '';

    name = "gitlens-${finalAttrs.version}.vsix";

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      inherit pnpm;
      fetcherVersion = 3;
      hash = "sha256-Yuxuqr1BiviSw+dGNHLs2jAy8ADlBvRks6Kmy7FmCMw=";
    };
  });
in
vscode-utils.buildVscodeExtension (finalAttrs: {
  inherit (finalAttrs.src) version;
  pname = "gitlens";
  src = vsix;
  vscodeExtName = "gitlens";
  vscodeExtPublisher = "eamodio";
  vscodeExtUniqueId = "${finalAttrs.vscodeExtPublisher}.${finalAttrs.vscodeExtName}";

  passthru = {
    updateScript = nix-update-script {
      attrPath = "vscode-extensions.eamodio.gitlens.vsix";
    };

    vsix = finalAttrs.src;
  };

  meta = {
    description = "Visual Studio Code extension that improves its built-in Git capabilities";

    longDescription = ''
      Supercharge the Git capabilities built into Visual Studio Code — Visualize code authorship at a glance via Git
      blame annotations and code lens, seamlessly navigate and explore Git repositories, gain valuable insights via
      powerful comparison commands, and so much more
    '';

    homepage = "https://gitlens.amod.io/";
    changelog = "https://marketplace.visualstudio.com/items/eamodio.gitlens/changelog";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      xiaoxiangmoe
      ratsclub
    ];

    downloadPage = "https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens";
  };
})
