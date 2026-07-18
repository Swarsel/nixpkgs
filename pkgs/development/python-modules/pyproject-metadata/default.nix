{
  lib,
  buildPythonPackage,
  fetchPypi,
  flit-core,
  packaging,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pyproject-metadata";
  version = "0.10.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-f1vQ7zmLYBaVVssX6iYdcVyvf4VhI4FR9RsjBQhLqNQ=";
    pname = "pyproject_metadata";
  };

  # Many broken tests, and missing test files
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ flit-core ];
  dependencies = [ packaging ];
  pyproject = true;
  pythonImportsCheck = [ "pyproject_metadata" ];

  meta = {
    description = "PEP 621 metadata parsing";
    homepage = "https://github.com/FFY00/python-pyproject-metadata";
    changelog = "https://github.com/pypa/pyproject-metadata/releases/tag/${version}";
    license = lib.licenses.mit;
  };
}
