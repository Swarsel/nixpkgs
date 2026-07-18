{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "bitstruct";
  version = "8.22.1";

  src = fetchFromGitHub {
    owner = "eerimoq";
    repo = "bitstruct";
    tag = version;
    hash = "sha256-Egiac+1x3HaaGV6ThjChfjKbT0WvQDb1EMuyOxLY7Kg=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "bitstruct" ];

  meta = {
    description = "Python bit pack/unpack package";
    homepage = "https://github.com/eerimoq/bitstruct";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jakewaksbaum ];
  };
}
