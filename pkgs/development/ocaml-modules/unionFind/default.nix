{
  lib,
  fetchFromGitLab,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "unionFind";
  version = "20250818";

  src = fetchFromGitLab {
    owner = "fpottier";
    repo = "unionfind";
    tag = finalAttrs.version;
    hash = "sha256-q/3Wx2/JvFO3m51OvMwO6bz+s7+4Vjs4pFgy5+OinNo=";
    domain = "gitlab.inria.fr";
  };

  minimalOCamlVersion = "4.12";

  meta = {
    description = "Implementations of the union-find data structure";
    homepage = "https://gitlab.inria.fr/fpottier/unionfind";
    license = lib.licenses.lgpl2Only;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
