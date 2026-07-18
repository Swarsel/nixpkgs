{
  lib,
  fetchFromGitLab,
  buildDunePackage,
  sedlex,
  xtmpl,
}:

buildDunePackage (finalAttrs: {
  pname = "higlo";
  version = "0.10.0";

  src = fetchFromGitLab {
    owner = "zoggy";
    repo = "higlo";
    rev = finalAttrs.version;
    hash = "sha256-A5Su4+eBOq/WNdY/3EBQ3KqrRQuaCI1x25cEuoZp4Mo=";
    domain = "framagit.org";
  };

  propagatedBuildInputs = [
    sedlex
    xtmpl
  ];

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "OCaml library for syntax highlighting";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ regnat ];
  };
})
