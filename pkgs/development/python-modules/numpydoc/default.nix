{
  lib,
  buildPythonPackage,
  fetchPypi,
  # dependencies
  jinja2,
  # tests
  matplotlib,
  pytest-cov-stub,
  pytestCheckHook,
  # build-system
  setuptools,
  sphinx,
  tabulate,
}:

buildPythonPackage rec {
  pname = "numpydoc";
  version = "1.10.0";

  src = fetchPypi {
    inherit pname;
    inherit version;
    hash = "sha256-P3lw9u7jCRImCmsxrHK7okMoMM1nIlaewX7o0+9f+gE=";
  };

  nativeCheckInputs = [
    matplotlib
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    jinja2
    sphinx
    tabulate
  ];

  disabledTests = [
    # https://github.com/numpy/numpydoc/issues/373
    "test_MyClass"
    "test_my_function"

    # AttributeError: 'MockApp' object has no attribute '_exception_on_warning'
    "test_mangle_docstring_validation_exclude"
    "test_mangle_docstring_validation_warnings"
    "test_mangle_docstrings_overrides"
    # AttributeError: 'MockBuilder' object has no attribute '_translator'
    "test_mangle_docstrings_basic"
    "test_mangle_docstrings_inherited_class_members"
  ];

  pyproject = true;
  pythonImportsCheck = [ "numpydoc" ];

  meta = {
    description = "Sphinx extension to support docstrings in Numpy format";
    homepage = "https://github.com/numpy/numpydoc";
    changelog = "https://github.com/numpy/numpydoc/releases/tag/v${version}";
    license = lib.licenses.free;
    mainProgram = "validate-docstrings";
  };
}
