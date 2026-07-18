{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
}:

buildPythonPackage rec {
  pname = "unpaddedbase64";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "matrix-org";
    repo = "python-${pname}";
    tag = "v${version}";
    sha256 = "1n6har8pxv0mqb96lanzihp1xf76aa17jw3977drb1fgz947pnmz";
  };

  nativeBuildInputs = [ poetry-core ];
  pyproject = true;

  meta = {
    description = "Unpadded Base64";
    homepage = "https://github.com/matrix-org/python-unpaddedbase64";
    license = lib.licenses.asl20;
  };
}
