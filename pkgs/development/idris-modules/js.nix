{
  lib,
  fetchFromGitHub,
  build-idris-package,
  contrib,
  pruviloj,
}:
build-idris-package {
  pname = "js";
  version = "2018-11-27";

  src = fetchFromGitHub {
    owner = "rbarreiro";
    repo = "idrisjs";
    rev = "1ce91ecec69a7174c20bff927aeac3928a01ed3f";
    sha256 = "13whhccb7yjq10hnngdc8bc9z9vvyir1wjkclpz006cr4cd266ca";
  };

  idrisDeps = [
    contrib
    pruviloj
  ];

  meta = {
    description = "Js libraries for idris";
    homepage = "https://github.com/rbarreiro/idrisjs";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.brainrape ];
  };
}
