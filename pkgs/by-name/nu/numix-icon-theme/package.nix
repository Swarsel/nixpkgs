{
  lib,
  fetchFromGitHub,
  adwaita-icon-theme,
  gitUpdater,
  gnome-icon-theme,
  gtk3,
  hicolor-icon-theme,
  kdePackages,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "numix-icon-theme";
  version = "25.10.26";

  src = fetchFromGitHub {
    owner = "numixproject";
    repo = "numix-icon-theme";
    tag = finalAttrs.version;
    hash = "sha256-YKR4dncq2uuX8CMJj/Zr/0pdl7gLC8VZGvb/HI1+Uwc=";
  };

  nativeBuildInputs = [
    gtk3
  ];

  propagatedBuildInputs = [
    adwaita-icon-theme
    kdePackages.breeze-icons
    gnome-icon-theme
    hicolor-icon-theme
  ];

  installPhase = ''
    runHook preInstall

    substituteInPlace Numix/index.theme --replace Breeze breeze

    mkdir -p $out/share/icons
    cp -a Numix{,-Light} $out/share/icons/

    for theme in $out/share/icons/*; do
      gtk-update-icon-cache $theme
    done

    runHook postInstall
  '';

  dontDropIconThemeCache = true;
  dontWrapQtApps = true;
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Numix icon theme";
    homepage = "https://numixproject.github.io";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ romildo ];
    # darwin cannot deal with file names differing only in case
    platforms = lib.platforms.linux;
  };
})
