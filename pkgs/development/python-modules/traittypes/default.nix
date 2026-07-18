{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pandas,
  pytestCheckHook,
  setuptools,
  traitlets,
  xarray,
}:

buildPythonPackage rec {
  pname = "traittypes";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "jupyter-widgets";
    repo = "traittypes";
    tag = version;
    hash = "sha256-RwEZs4QFK+IrPFPBI7+jnQSFQryQFzEbrnOF8OyExuk=";
  };

  nativeCheckInputs = [
    numpy
    pandas
    xarray
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ traitlets ];

  disabledTests = [
    # AssertionError; see https://github.com/jupyter-widgets/traittypes/issues/55
    "test_initial_values"
  ];

  pyproject = true;
  pythonImportsCheck = [ "traittypes" ];

  meta = {
    description = "Trait types for NumPy, SciPy, XArray, and Pandas";
    homepage = "https://github.com/jupyter-widgets/traittypes";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
