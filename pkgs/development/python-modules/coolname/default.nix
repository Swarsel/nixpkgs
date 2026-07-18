{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "coolname";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "alexanderlukanin13";
    repo = "coolname";
    tag = version;
    hash = "sha256-6po9SJGVvOEoSSBtRsbbFE59APFrSkF7uQqaJA8ejoU=";
  };

  # Tests require coolname.data to be packaged
  doCheck = false;

  build-system = [
    setuptools
  ];

  pyproject = true;

  pythonImportsCheck = [
    "coolname"
  ];

  meta = {
    description = "Random Name and Slug Generator";
    homepage = "https://github.com/alexanderlukanin13/coolname";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ happysalada ];
  };
}
