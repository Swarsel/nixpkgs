{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "pgf-umlcd";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "pgf-tikz";
    repo = "pgf-umlcd";
    tag = finalAttrs.version;
    hash = "sha256-92bfBcQfnalYoVxlVRjbRXhWt+CbS8PtiMmFIqbgo7A=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/texmf-nix
    cp -prd doc tex/latex $out/share/texmf-nix/

    runHook postInstall
  '';

  meta = {
    description = "Some LaTeX macros for UML Class Diagrams";
    homepage = "https://github.com/pgf-tikz/pgf-umlcd";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
