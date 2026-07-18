{
  lib,
  fetchFromGitHub,
  gitUpdater,
  gtk3,
  hicolor-icon-theme,
  numix-icon-theme,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "numix-icon-theme-circle";
  version = "26.02.21";

  src = fetchFromGitHub {
    owner = "numixproject";
    repo = "numix-icon-theme-circle";
    rev = version;
    sha256 = "sha256-zkUqbM120mZ4UzBXPEDtSO1cauRNG7wxPM3AmtINWEU=";
  };

  nativeBuildInputs = [ gtk3 ];

  propagatedBuildInputs = [
    numix-icon-theme
    hicolor-icon-theme
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/icons
    cp -a Numix-Circle{,-Light} $out/share/icons

    for panel in $out/share/icons/*/*/panel; do
      ln -sf $(realpath ${numix-icon-theme}/share/icons/Numix/16/$(readlink $panel)) $panel
    done

    for theme in $out/share/icons/*; do
      gtk-update-icon-cache $theme
    done

    runHook postInstall
  '';

  dontDropIconThemeCache = true;
  dontWrapQtApps = true;
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Numix icon theme (circle version)";
    homepage = "https://numixproject.github.io";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ romildo ];
    # darwin cannot deal with file names differing only in case
    platforms = lib.platforms.linux;
  };
}
