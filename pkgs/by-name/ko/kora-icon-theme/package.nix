{
  lib,
  fetchFromGitHub,
  adwaita-icon-theme,
  gitUpdater,
  gtk3,
  hicolor-icon-theme,
  kdePackages,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "kora-icon-theme";
  version = "1.6.5";

  src = fetchFromGitHub {
    owner = "bikass";
    repo = "kora";
    tag = "v${version}";
    hash = "sha256-Oralfx5MzCzkx+c+zwtFp8q83oKrNINd/PmVeugNKGo=";
  };

  nativeBuildInputs = [
    gtk3
  ];

  propagatedBuildInputs = [
    adwaita-icon-theme
    kdePackages.breeze-icons
    hicolor-icon-theme
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/icons
    cp -a kora* $out/share/icons/
    rm $out/share/icons/kora*/create-new-icon-theme.cache.sh

    for theme in $out/share/icons/*; do
      gtk-update-icon-cache -f $theme
    done

    runHook postInstall
  '';

  dontDropIconThemeCache = true;
  # breeze-icons propagates qtbase
  dontWrapQtApps = true;

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = {
    description = "SVG icon theme in four variants";
    homepage = "https://github.com/bikass/kora";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ romildo ];
    platforms = lib.platforms.linux;
  };
}
