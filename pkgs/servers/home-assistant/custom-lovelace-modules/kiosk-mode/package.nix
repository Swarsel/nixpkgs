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
  pname = "kiosk-mode";
  version = "14.0.1";

  src = fetchFromGitHub {
    owner = "nemesisre";
    repo = "kiosk-mode";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eQ2dYXmx4nnk/1bbTayPezPyghBo5UbNWf3USY20ePg=";
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
    hash = "sha256-bCtk+cqWnYvPo4VsvLaN+m0LIlP8jgb951aIf1emGZg=";
  };

  meta = {
    description = "Hides the Home Assistant header and/or sidebar";
    homepage = "https://github.com/NemesisRE/kiosk-mode";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ teeco123 ];
    platforms = lib.platforms.all;
  };
})
