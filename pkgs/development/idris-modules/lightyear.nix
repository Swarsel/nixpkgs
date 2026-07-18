{
  lib,
  fetchFromGitHub,
  build-idris-package,
  effects,
}:
build-idris-package {
  pname = "lightyear";
  version = "2017-09-10";

  src = fetchFromGitHub {
    owner = "ziman";
    repo = "lightyear";
    rev = "f737e25a09c1fe7c5fff063c53bd7458be232cc8";
    sha256 = "05x66abhpbdm6yr0afbwfk6w04ysdk78gylj5alhgwhy4jqakv29";
  };

  idrisDeps = [ effects ];

  meta = {
    description = "Parser combinators for Idris";
    homepage = "https://github.com/ziman/lightyear";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      siddharthist
      brainrape
    ];
  };
}
