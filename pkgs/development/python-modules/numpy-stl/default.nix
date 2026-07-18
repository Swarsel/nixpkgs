{
  lib,
  buildPythonPackage,
  cython,
  fetchPypi,
  numpy,
  pytestCheckHook,
  python-utils,
  setuptools,
}:

buildPythonPackage rec {
  pname = "numpy-stl";
  version = "3.2.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-WiDD95zdqgq8akuZ9Uhqzu1PiBUvKbGaV6zIROGD/U0=";
    pname = "numpy_stl";
  };

  nativeBuildInputs = [ cython ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    numpy
    python-utils
  ];

  pyproject = true;
  pythonImportsCheck = [ "stl" ];

  meta = {
    description = "Library to make reading, writing and modifying both binary and ascii STL files easy";
    homepage = "https://github.com/WoLpH/numpy-stl/";
    changelog = "https://github.com/wolph/numpy-stl/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
