{
  lib,
  fetchFromGitHub,
  kdePackages,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "kwin-effect-geometry-change";
  version = "1.5";

  src = fetchFromGitHub {
    owner = "peterfajdiga";
    repo = "kwin4_effect_geometry_change";
    tag = "v${finalAttrs.version}";
    hash = "sha256-p4FpqagR8Dxi+r9A8W5rGM5ybaBXP0gRKAuzigZ1lyA=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    kdePackages.kpackage
    kdePackages.kwin
  ];

  installPhase = ''
    runHook preInstall

    kpackagetool6 --type=KWin/Effect --install=./package --packageroot=$out/share/kwin/effects

    runHook postInstall
  '';

  __structuredAttrs = true;
  dontBuild = true;
  dontWrapQtApps = true;

  meta = {
    description = "KWin animation for windows moved or resized by programs or scripts";
    homepage = "https://github.com/peterfajdiga/kwin4_effect_geometry_change";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ couldbemathijs ];
    platforms = lib.platforms.linux;
  };
})
