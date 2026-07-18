{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "pgfplots";
  version = "1.18.2";

  src = fetchFromGitHub {
    owner = "pgf-tikz";
    repo = "pgfplots";
    tag = finalAttrs.version;
    hash = "sha256-Qw7H/oCZDtqm6sdCfwDm9SbIxdoemmhj/XCaHZf5/5c=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/texmf-nix
    cp -prd doc tex/{context,generic,latex,plain} $out/share/texmf-nix/

    runHook postInstall
  '';

  meta = {
    description = "TeX package to draw plots directly in TeX in two and three dimensions";
    homepage = "https://pgfplots.sourceforge.net";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
