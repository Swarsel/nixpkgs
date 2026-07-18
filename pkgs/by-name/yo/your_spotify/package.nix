{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  fetchPnpmDeps,
  makeWrapper,
  nix-update-script,
  nixosTests,
  nodejs,
  pnpmConfigHook,
  pnpm_11,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "your_spotify_server";
  version = "1.20.0";

  src = fetchFromGitHub {
    owner = "Yooooomi";
    repo = "your_spotify";
    tag = finalAttrs.version;
    hash = "sha256-0XGq4UVaNN1gTJLta0o9DnQwGwJ+S7HlGFY6DPAdGKY=";
  };

  nativeBuildInputs = [
    makeWrapper
    pnpmConfigHook
    pnpm_11
    nodejs
  ];

  buildPhase = ''
    runHook preBuild
    pushd ./apps/server/
    pnpm run build
    popd
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/your_spotify
    cp -r apps/server/build $out/share/your_spotify/
    mkdir -p $out/bin
    makeWrapper ${lib.escapeShellArg (lib.getExe nodejs)} "$out/bin/your_spotify_migrate" \
      --add-flags "$out/share/your_spotify/build/index.js" --add-flags "--migrate"
    makeWrapper ${lib.escapeShellArg (lib.getExe nodejs)} "$out/bin/your_spotify_server" \
      --add-flags "$out/share/your_spotify/build/index.js"

    runHook postInstall
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 4;
    hash = "sha256-eUAzQ+LV+RZs/QEb5r7l9cisBjjWU8eGMm2r9ZNXmX8=";
    pnpm = pnpm_11;
  };

  passthru = {
    client = callPackage ./client.nix {
      inherit (finalAttrs)
        src
        version
        pnpmDeps
        meta
        ;
    };

    tests = {
      inherit (nixosTests) your_spotify;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Self-hosted application that tracks what you listen and offers you a dashboard to explore statistics about it";
    homepage = "https://github.com/Yooooomi/your_spotify";
    changelog = "https://github.com/Yooooomi/your_spotify/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ patrickdag ];
    mainProgram = "your_spotify_server";
  };
})
