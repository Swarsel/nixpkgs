{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  python,
  robotframework,
  setuptools,
}:

buildPythonPackage rec {
  pname = "robotstatuschecker";
  version = "4.1.1";

  # no tests included in PyPI tarball
  src = fetchFromGitHub {
    owner = "robotframework";
    repo = "statuschecker";
    tag = "v${version}";
    hash = "sha256-YyiGd3XSIe+4PEL2l9LYDGH3lt1iRAAJflcBGYXaBzY=";
  };

  checkPhase = ''
    runHook preCheck

    ${python.interpreter} test/run.py

    runHook postCheck
  '';

  build-system = [ setuptools ];
  dependencies = [ robotframework ];
  pyproject = true;

  meta = {
    description = "Tool for checking that Robot Framework test cases have expected statuses and log messages";
    homepage = "https://github.com/robotframework/statuschecker";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
