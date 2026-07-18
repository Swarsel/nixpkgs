{
  lib,
  fetchFromGitLab,
  hicolor-icon-theme,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "antu-icons";
  version = "2.0"; # https://www.opendesktop.org/p/1188266/

  src = fetchFromGitLab {
    owner = "froodo_alexis";
    repo = "Antu-icons";
    rev = "a12a9e559b59c8ded47531e299a5516718ef9a28";
    hash = "sha256-CLcr+X/b0moVEBV0O/dzCDq4w5G2+KRLUBdqKm0eAKA=";
  };

  propagatedBuildInputs = [ hicolor-icon-theme ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/icons/antu-icons
    cp -r * $out/share/icons/antu-icons

    # Remove broken symlinks
    find $out/share/icons/antu-icons -xtype l -delete
    runHook postInstall
  '';

  dontDropIconThemeCache = true;

  meta = {
    description = "Smooth icon theme designed for Plasma Desktop";
    homepage = "https://gitlab.com/froodo_alexis/Antu-icons";
    license = lib.licenses.cc-by-nc-sa-30;
    maintainers = with lib.maintainers; [ iamanaws ];
    platforms = lib.platforms.linux;
  };
}
