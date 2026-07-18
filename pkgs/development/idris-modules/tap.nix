{
  lib,
  fetchFromGitHub,
  build-idris-package,
  contrib,
}:
build-idris-package {
  pname = "tap";
  version = "2017-04-08";

  src = fetchFromGitHub {
    owner = "ostera";
    repo = "tap-idris";
    rev = "0d019333e1883c1d60e151af1acb02e2b531e72f";
    sha256 = "0fhlmmivq9xv89r7plrnhmvay1j7bapz3wh7y8lygwvcrllh9zxs";
  };

  idrisDeps = [ contrib ];
  ipkgName = "TAP";

  meta = {
    description = "Simple TAP producer and consumer/reporter for Idris";
    homepage = "https://github.com/ostera/tap-idris";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.brainrape ];
  };
}
