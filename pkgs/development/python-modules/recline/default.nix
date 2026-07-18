{
  lib,
  fetchFromGitHub,
  argcomplete,
  buildPythonPackage,
  pudb,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "recline";
  version = "2025.12";

  src = fetchFromGitHub {
    owner = "NetApp";
    repo = "recline";
    tag = "v${version}";
    sha256 = "sha256-xEH6fEq84nD3X6bPj1Yw36mjwHKlFKsVaMh4Iogzl18=";
  };

  nativeCheckInputs = [
    pudb
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ argcomplete ];
  pyproject = true;
  pythonImportsCheck = [ "recline" ];

  meta = {
    description = "This library helps you quickly implement an interactive command-based application";
    homepage = "https://github.com/NetApp/recline";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
