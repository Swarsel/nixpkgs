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
}:
let
  pnpm = pnpm_10;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "nrm";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "pana";
    repo = "nrm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2P0dSZa17A3NslNatCx1edLnrcDtGGpOlk6srcvjL1Y=";
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

    mkdir -p $out/lib/node_modules/nrm
    mkdir $out/bin
    mv * $out/lib/node_modules/nrm/
    makeWrapper ${lib.getExe nodejs} $out/bin/nrm \
      --add-flags "$out/lib/node_modules/nrm/dist/index.js" \
      --set "NODE_PATH" "$out/lib/node_modules/nrm/node_modules"

    runHook postInstall
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-DvhUXkh9Ijuik9uWzPOtM1idSNSaJxDiRHWpUMepf3U=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Helps you switch between npm registries easily";
    homepage = "https://github.com/Pana/nrm";
    changelog = "https://github.com/Pana/nrm/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "nrm";
  };
})
