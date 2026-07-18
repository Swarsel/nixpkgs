{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "pgf";
  version = "2.10";

  src = fetchFromGitHub {
    owner = "pgf-tikz";
    repo = "pgf";
    tag = finalAttrs.version;
    hash = "sha256-AA+XFhEkJifODJb6SppnxhR4lMlMNaH+k10UF6QisJ8=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/texmf-nix
    cp -prd context doc generic latex plain $out/share/texmf-nix/

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "Portable Graphic Format for TeX";
    homepage = "https://github.com/pgf-tikz/pgf";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    branch = lib.versions.major finalAttrs.version;
  };
})
