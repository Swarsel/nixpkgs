{
  lib,
  fetchFromGitLab,
  buildDunePackage,
  yojson,
}:

buildDunePackage (finalAttrs: {
  pname = "ocf";
  version = "0.9.0";

  src = fetchFromGitLab {
    owner = "zoggy";
    repo = "ocf";
    tag = finalAttrs.version;
    hash = "sha256-tTNpvncLO/WfcMbjqRfqzcdPv2Bd877fOU5AZlkkcXA=";
    domain = "framagit.org";
  };

  patches = ./yojson.patch;
  propagatedBuildInputs = [ yojson ];

  meta = {
    description = "OCaml library to read and write configuration options in JSON syntax";
    homepage = "https://zoggy.frama.io/ocf/";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ regnat ];
  };
})
