{
  lib,
  buildPythonPackage,
  fetchPypi,
  ipywidgets,
  jupyter-packaging,
  nbval,
  numpy,
  pytestCheckHook,
  six,
  traittypes,
}:

buildPythonPackage rec {
  pname = "ipydatawidgets";
  version = "4.3.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-OU8kiVdlh8/XVTd6CaBn9GytIggZZQkgIf0avL54Uqg=";
  };

  nativeBuildInputs = [ jupyter-packaging ];

  propagatedBuildInputs = [
    ipywidgets
    numpy
    six
    traittypes
  ];

  nativeCheckInputs = [
    pytestCheckHook
    nbval
  ];

  # Tests bind ports
  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;

  disabledTestPaths = [
    # https://github.com/vidartf/ipydatawidgets/issues/62
    "ipydatawidgets/tests/test_ndarray_trait.py::test_dtype_coerce"

    # https://github.com/vidartf/ipydatawidgets/issues/63
    "examples/test.ipynb::Cell 3"
  ];

  format = "setuptools";
  setupPyBuildFlags = [ "--skip-npm" ];

  meta = {
    description = "Widgets to help facilitate reuse of large datasets across different widgets";
    homepage = "https://github.com/vidartf/ipydatawidgets";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
