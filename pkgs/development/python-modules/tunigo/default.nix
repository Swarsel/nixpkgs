{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mock,
  pytest,
  requests,
  responses,
}:

buildPythonPackage rec {
  pname = "tunigo";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "trygveaa";
    repo = "python-tunigo";
    rev = "v${version}";
    sha256 = "07q9girrjjffzkn8xj4l3ynf9m4psi809zf6f81f54jdb330p2fs";
  };

  propagatedBuildInputs = [ requests ];

  nativeCheckInputs = [
    mock
    responses
    pytest
  ];

  checkPhase = ''
    py.test
  '';

  format = "setuptools";

  meta = {
    description = "Python API for the browse feature of Spotify";
    homepage = "https://github.com/trygveaa/python-tunigo";
    license = lib.licenses.asl20;
  };
}
