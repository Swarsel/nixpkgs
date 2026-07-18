{
  lib,
  fetchFromGitHub,
  adwaita-icon-theme,
  gnome-icon-theme,
  gtk3,
  hicolor-icon-theme,
  humanity-icon-theme,
  stdenvNoCC,
  ubuntu-themes,
}:

stdenvNoCC.mkDerivation rec {
  pname = "mint-x-icons";
  version = "1.7.6";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "mint-x-icons";
    rev = version;
    hash = "sha256-gGldt2tGko3IukpKjn0xGAe4cL21YPCECJfcOX5F8n0=";
  };

  nativeBuildInputs = [
    gtk3
  ];

  propagatedBuildInputs = [
    adwaita-icon-theme
    gnome-icon-theme
    hicolor-icon-theme
    humanity-icon-theme
    ubuntu-themes # provides ubuntu-mono-dark
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    mv usr/share $out

    for theme in $out/share/icons/*; do
      gtk-update-icon-cache $theme
    done

    runHook postInstall
  '';

  dontDropIconThemeCache = true;

  meta = {
    description = "Mint/metal theme based on mintified versions of Clearlooks Revamp, Elementary and Faenza";
    homepage = "https://github.com/linuxmint/mint-x-icons";
    license = lib.licenses.gpl3Plus; # from debian/copyright
    platforms = lib.platforms.linux;
    teams = [ lib.teams.cinnamon ];
  };
}
