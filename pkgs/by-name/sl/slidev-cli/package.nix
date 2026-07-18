{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  nix-update-script,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
}:
let
  pnpm = pnpm_10;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "slidev-cli";
  version = "52.15.2";

  src = fetchFromGitHub {
    owner = "slidevjs";
    repo = "slidev";
    tag = "v${finalAttrs.version}";
    hash = "sha256-h9gVfGMLTm8NDSAR/OKl5XJRBduAPHQ9mp+jtNYtxFI=";
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
  ];

  buildInputs = [
    nodejs
  ];

  buildPhase = ''
    runHook preBuild

    pnpm -r --filter=@slidev/cli... --parallel run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    rm -rf node_modules packages/slidev/node_modules
    pnpm install --force --offline --production --ignore-scripts --filter=@slidev/cli...

    mkdir -p $out/lib/node_modules/slidev-cli/
    mkdir $out/bin
    mv ./packages ./node_modules ./package.json $out/lib/node_modules/slidev-cli

    ln -s $out/lib/node_modules/slidev-cli/packages/slidev/bin/slidev.mjs $out/bin/slidev
    chmod +x $out/bin/slidev
    patchShebangs $out/bin/slidev

    runHook postInstall
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      pnpmWorkspaces
      ;

    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-DGDzNvau1XjPjkGZqcFZGkjYd3cneXO/gCdnwjjkQDY=";
  };

  pnpmWorkspaces = [ "@slidev/cli..." ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Presentation slides for developers";
    homepage = "https://sli.dev";
    changelog = "https://github.com/slidevjs/slidev/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      pyrox0
      pluiedev
    ];

    mainProgram = "slidev";
  };
})
