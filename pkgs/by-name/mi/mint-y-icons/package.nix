{
  lib,
  fetchFromGitHub,
  adwaita-icon-theme,
  gnome-icon-theme,
  gtk3,
  hicolor-icon-theme,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "mint-y-icons";
  version = "1.9.2";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "mint-y-icons";
    rev = version;
    hash = "sha256-kB6JEl6CjVfZ/aY9qotfTogKxcPdZzNLlbA9OoKEvAc=";
  };

  nativeBuildInputs = [
    gtk3
  ];

  propagatedBuildInputs = [
    adwaita-icon-theme
    gnome-icon-theme
    hicolor-icon-theme
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
    description = "Mint-Y icon theme";
    homepage = "https://github.com/linuxmint/mint-y-icons";
    license = lib.licenses.gpl3; # from debian/copyright
    platforms = lib.platforms.linux;
    teams = [ lib.teams.cinnamon ];
  };
}
