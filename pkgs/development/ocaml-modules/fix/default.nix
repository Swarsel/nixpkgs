{
  lib,
  fetchFromGitLab,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "fix";
  version = "20250919";

  src = fetchFromGitLab {
    owner = "fpottier";
    repo = "fix";
    tag = finalAttrs.version;
    hash = "sha256-CVxOLlSKKX1kb1bi6IbSo7SH5GsVynI4de0c5NUmq+s=";
    domain = "gitlab.inria.fr";
  };

  minimalOCamlVersion = "4.03";

  meta = {
    description = "Simple OCaml module for computing the least solution of a system of monotone equations";
    homepage = "https://gitlab.inria.fr/fpottier/fix/";
    license = lib.licenses.lgpl2Only;
    maintainers = with lib.maintainers; [ vbgl ];
  };
})
