{
  lib,
  fetchFromGitHub,
  fetchPnpmDeps,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
  stdenvNoCC,
}:
let
  pnpm = pnpm_10;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "custom-sidebar";
  version = "16.0.0";

  src = fetchFromGitHub {
    owner = "elchininet";
    repo = "custom-sidebar";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ST7wgxl9bpsHvguYbZQYYWO1KkinSrNCrbugVBJGvJo=";
  };

  nativeBuildInputs = [
    pnpmConfigHook
    pnpm
    nodejs
  ];

  buildPhase = ''
    runHook preBuild

    pnpm run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp dist/* "$out"

    runHook postInstall
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-SbjE9u2RZ8M6GHxk7NkvyihGDiO6v/1LHywvaP8OcQM=";
  };

  passthru.entrypoint = "custom-sidebar-yaml.js";

  meta = {
    description = "Custom plugin that allows you to personalise the Home Assistant's sidebar per user or device basis";
    homepage = "https://elchininet.github.io/custom-sidebar";
    changelog = "https://github.com/elchininet/custom-sidebar/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ kranzes ];
    downloadPage = "https://github.com/elchininet/custom-sidebar";
  };
})
