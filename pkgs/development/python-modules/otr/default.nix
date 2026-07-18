{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  gmpy2,
  python3-application,
  setuptools,
}:

buildPythonPackage rec {
  pname = "otr";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "AGProjects";
    repo = "python3-otr";
    tag = version;
    hash = "sha256-jCyPEdWDEW1x0Id//yM67SvKvYpdyIfPmcCWiRgwvb0=";
  };

  checkPhase = ''
    runHook preCheck

    python3 test.py

    runHook postCheck
  '';

  build-system = [ setuptools ];

  dependencies = [
    cryptography
    gmpy2
    python3-application
  ];

  pyproject = true;
  pythonImportsCheck = [ "otr" ];

  meta = {
    description = "Off-The-Record Messaging protocol implementation for Python";
    homepage = "https://github.com/AGProjects/python3-otr";
    license = lib.licenses.lgpl21Plus;

    teams = [
      lib.teams.ngi
    ];
  };
}
