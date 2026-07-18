{
  lib,
  fetchFromGitHub,
  nix-update-script,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "thunderkittens";
  version = "0-unstable-2026-06-15";

  src = fetchFromGitHub {
    owner = "HazyResearch";
    repo = "ThunderKittens";
    rev = "02e9acbd8c330564357a9e2df929e938ac67d6d0";
    hash = "sha256-GXrKCMKMDnQO7hNj4WZmmANSVJqEioIArwQWoE+/jVM=";
  };

  strictDeps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/include
    cp -r include/* $out/include/

    runHook postInstall
  '';

  __structuredAttrs = true;
  dontBuild = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "Tile primitives for speedy CUDA deep learning kernels";
    homepage = "https://github.com/HazyResearch/ThunderKittens";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    platforms = lib.platforms.linux;
  };
}
