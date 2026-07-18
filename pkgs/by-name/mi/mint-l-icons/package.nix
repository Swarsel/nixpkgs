{
  lib,
  fetchFromGitHub,
  adwaita-icon-theme,
  gnome-icon-theme,
  gtk3,
  hicolor-icon-theme,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "mint-l-icons";
  version = "1.8.1";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "mint-l-icons";
    # They don't really do tags, this is just a named commit.
    rev = "f9f679c9bed2f2462040fed9872988e705bf5630";
    hash = "sha256-nfdG1AVF/bIgRZ+9dZ14qw5cajhO3Q6oY5ZqkgTnuCA=";
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

  # FIXME: https://hydra.nixos.org/build/287344480/nixlog/5
  dontCheckForBrokenSymlinks = true;
  dontDropIconThemeCache = true;

  meta = {
    description = "Mint-L icon theme";
    homepage = "https://github.com/linuxmint/mint-l-icons";
    license = lib.licenses.gpl3Plus; # from debian/copyright
    platforms = lib.platforms.linux;
    teams = [ lib.teams.cinnamon ];
  };
}
