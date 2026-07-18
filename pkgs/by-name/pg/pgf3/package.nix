{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "pgf";
  version = "3.1.11a";

  src = fetchFromGitHub {
    owner = "pgf-tikz";
    repo = "pgf";
    tag = finalAttrs.version;
    hash = "sha256-+OxQ7sf5qh9hiVdCapJOUUwxDNsbvCXZEupN52wqldE=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/texmf-nix
    cp -prd doc source tex/{context,generic,latex,plain} $out/share/texmf-nix/

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "Portable Graphic Format for TeX - version ${finalAttrs.version}";
    homepage = "https://github.com/pgf-tikz/pgf";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    branch = lib.versions.major finalAttrs.version;
  };
})
