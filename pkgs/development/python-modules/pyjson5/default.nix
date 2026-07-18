{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "pyjson5";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "Kijewski";
    repo = "pyjson5";
    tag = "v${version}";
    hash = "sha256-SonObL4watru9+YDiw4K7Mo5BOKWmhp1R/IZ54H9Db0=";
    fetchSubmodules = true;
  };

  # Module has no tests
  doCheck = false;

  build-system = [
    cython
    setuptools
    wheel
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyjson5" ];

  meta = {
    description = "JSON5 serializer and parser library";
    homepage = "https://github.com/Kijewski/pyjson5";
    changelog = "https://github.com/Kijewski/pyjson5/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
