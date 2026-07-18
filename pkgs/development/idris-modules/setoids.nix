{
  lib,
  fetchFromGitHub,
  build-idris-package,
  contrib,
}:
build-idris-package {
  pname = "setoids";
  version = "2018-06-18";

  src = fetchFromGitHub {
    owner = "danilkolikov";
    repo = "setoids";
    rev = "41b4af3b1a537d9471107a639ad77c7abee2de18";
    sha256 = "0fl1g59s16vnrdnplps5ncv27j7a93nxp9cmqp2iavjxlzlzin1v";
  };

  idrisDeps = [ contrib ];

  meta = {
    description = "Idris proofs for extensional equalities";
    homepage = "https://github.com/danilkolikov/setoids";
    maintainers = [ lib.maintainers.brainrape ];
  };
}
