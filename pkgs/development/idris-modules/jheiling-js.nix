{
  lib,
  fetchFromGitHub,
  build-idris-package,
  contrib,
  jheiling-extras,
}:
build-idris-package {
  pname = "jheiling-js";
  version = "2016-03-09";

  src = fetchFromGitHub {
    owner = "jheiling";
    repo = "idris-js";
    rev = "59763cd0c9715a9441931ae1077e501bb2ec6020";
    sha256 = "1mvpxwszh56cfrf509qiadn7gp2l4syanhvdq6v1br0y03g8wk9v";
  };

  idrisDeps = [
    contrib
    jheiling-extras
  ];

  ipkgName = "js";

  meta = {
    description = "Js library for Idris";
    homepage = "https://github.com/jheiling/idris-js";
    license = lib.licenses.unlicense;
    maintainers = [ lib.maintainers.brainrape ];
  };
}
