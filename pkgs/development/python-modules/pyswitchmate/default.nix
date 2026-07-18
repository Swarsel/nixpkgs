{
  lib,
  fetchFromGitHub,
  bleak,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyswitchmate";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "Danielhiversen";
    repo = "pySwitchmate";
    tag = version;
    hash = "sha256-14rjlIsSFNP2OzuRamAJw9BaA+Z5EuQBEsrD02uQdFk=";
  };

  # Project has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ bleak ];
  pyproject = true;
  pythonImportsCheck = [ "switchmate" ];

  meta = {
    description = "A library to communicate with Switchmate";
    homepage = "https://github.com/Danielhiversen/pySwitchmate";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
