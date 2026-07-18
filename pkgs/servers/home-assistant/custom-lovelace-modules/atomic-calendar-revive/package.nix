{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  nix-update-script,
  nodejs,
  pnpmConfigHook,
  pnpm_11,
}:

let
  pnpm = pnpm_11;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "atomic-calendar-revive";
  version = "10.3.1";

  src = fetchFromGitHub {
    owner = "totaldebug";
    repo = "atomic-calendar-revive";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qqEQrbLQU5zhMcDDtg5f9Py4raOSYKCy4uv2omK6eO8=";
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

    mkdir $out
    cp ./dist/atomic-calendar-revive.js $out

    runHook postInstall
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-RR+QxRJvxd8YXE4Siw4CmUGUC4mrPfstSIkHqoHvldE=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Advanced calendar card for Home Assistant Lovelace";
    homepage = "https://github.com/totaldebug/atomic-calendar-revive";
    changelog = "https://github.com/totaldebug/atomic-calendar-revive/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
    platforms = lib.platforms.all;
  };
})
