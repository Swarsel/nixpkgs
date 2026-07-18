{
  lib,
  fetchFromGitHub,
  kdePackages,
  nix-update-script,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "application-title-bar";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "antroids";
    repo = "application-title-bar";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Zph+TwPXyf2r3PpJqWSdR0V9fFt2b2XWVfsAzuY3bP4=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/plasma/plasmoids/com.github.antroids.application-title-bar
    cp -r package/* $out/share/plasma/plasmoids/com.github.antroids.application-title-bar
    runHook postInstall
  '';

  dontWrapQtApps = true;
  propagatedUserEnvPkgs = with kdePackages; [ kconfig ];
  passthru.updateScript = nix-update-script { };

  meta = {
    inherit (kdePackages.kwindowsystem.meta) platforms;
    description = "KDE Plasma6 widget with window controls";
    homepage = "https://github.com/antroids/application-title-bar";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ HeitorAugustoLN ];
  };
})
