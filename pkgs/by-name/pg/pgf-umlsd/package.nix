{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "pgf-umlcd";
  version = "0-unstable-2020-05-28";

  src = fetchFromGitHub {
    owner = "pgf-tikz";
    repo = "pgf-umlsd";
    rev = "8766cc18596dbfa66202ceca01c62cab1c3ed6a2";
    hash = "sha256-gSBO7uDPMer9XyHfs0rr+2lricN5Nb4cOlShCsk0cPc=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/texmf-nix
    cp -prd doc tex/latex $out/share/texmf-nix/

    runHook postInstall
  '';

  meta = {
    description = "Some LaTeX macros for UML Sequence Diagrams";
    homepage = "https://github.com/pgf-tikz/pgf-umlsd";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
}
