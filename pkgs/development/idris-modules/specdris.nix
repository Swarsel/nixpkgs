{
  lib,
  fetchFromGitHub,
  build-idris-package,
  effects,
}:
build-idris-package {
  pname = "specdris";
  version = "2018-01-23";

  src = fetchFromGitHub {
    owner = "pheymann";
    repo = "specdris";
    rev = "625f88f5e118e53f30bcf5e5f3dcf48eb268ac21";
    sha256 = "1gc717xf4i7z75aqazy5wqm7b1dqfyx5pprdypxz1h3980m67fsa";
  };

  # tests use a different ipkg and directory structure
  doCheck = false;
  idrisDeps = [ effects ];

  meta = {
    description = "Testing library for Idris";
    homepage = "https://github.com/pheymann/specdris";
    license = lib.licenses.mit;
  };
}
