{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  future,
  python,
  pythonOlder,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "word2number";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "akshaynagpal";
    repo = "w2n";
    tag = version;
    hash = "sha256-dgHPEfieNDZnP6+YvywvN3ZzmeICav0WMYKkWDSJ/LE=";
  };

  checkPhase = ''
    ${lib.getExe python} unit_testing.py
  '';

  build-system = [
    setuptools-scm
  ];

  dependencies = lib.optionals (pythonOlder "3.13") [
    future
  ];

  pyproject = true;

  pythonImportsCheck = [
    "word2number"
  ];

  meta = {
    description = "Convert number words (eg. twenty one) to numeric digits (21)";
    homepage = "http://w2n.readthedocs.io/";
    changelog = "https://github.com/akshaynagpal/w2n/releases/tag/${version}";
    license = [ lib.licenses.mit ];
    maintainers = [ lib.maintainers.booxter ];
  };
}
