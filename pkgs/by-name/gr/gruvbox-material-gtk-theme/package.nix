{
  lib,
  fetchFromGitHub,
  gtk-engine-murrine,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "gruvbox-material-gtk-theme";
  version = "0-unstable-2024-08-09";

  src = fetchFromGitHub {
    owner = "TheGreatMcPain";
    repo = "gruvbox-material-gtk";
    rev = "808959bcfe8b9409b49a7f92052198f0882ae8bc";
    hash = "sha256-NHjE/HI/BJyjrRfoH9gOKIU8HsUIBPV9vyvuW12D01M=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/"{themes,icons}
    for i in "icons" "themes"; do
      cp -a "$i/"* "$out/share/$i"
    done
    runHook postInstall
  '';

  dontBuild = true;
  propagatedUserEnvPkgs = [ gtk-engine-murrine ];

  meta = {
    description = "GTK Theme based off of the Gruvbox Material colour palette";
    homepage = "https://github.com/TheGreatMcPain/gruvbox-material-gtk";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.amadaluzia ];
    platforms = lib.platforms.unix;
  };
}
