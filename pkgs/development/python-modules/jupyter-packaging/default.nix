{
  lib,
  buildPythonPackage,
  deprecation,
  fetchPypi,
  fetchpatch,
  hatchling,
  packaging,
  pytest-timeout,
  pytestCheckHook,
  setuptools,
  tomlkit,
}:

buildPythonPackage rec {
  pname = "jupyter-packaging";
  version = "0.12.3";

  src = fetchPypi {
    inherit version;
    hash = "sha256-nZsrY7l//WeovFORwypCG8QVsmSjLJnk2NjdMdqunPQ=";
    pname = "jupyter_packaging";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-NlO07wBCutAJ1DgoT+rQFkuC9Y+DyF1YFlTwWpwsJzo=";
      name = "setuptools-68-test-compatibility.patch";
      url = "https://github.com/jupyter/jupyter-packaging/commit/e963fb27aa3b58cd70c5ca61ebe68c222d803b7e.patch";
    })
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-timeout
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  build-system = [ hatchling ];

  dependencies = [
    deprecation
    packaging
    setuptools
    tomlkit
  ];

  disabledTests = [
    # disable tests depending on network connection
    "test_develop"
    "test_install"
    # Avoid unmaintained "mocker" fixture library, and calls to dependent "build" module
    "test_build"
    "test_npm_build"
    "test_create_cmdclass"
    "test_ensure_with_skip_npm"
  ];

  pyproject = true;

  pytestFlags = [
    "-Wignore::DeprecationWarning"
    # The 'wheel' package is no longer the canonical location of the 'bdist_wheel' command, and will be removed in a future release. Please update to setuptools v70.1 or later which contains an integrated version of this command.
    "-Wignore::FutureWarning"
  ];

  pythonImportsCheck = [ "jupyter_packaging" ];

  meta = {
    description = "Jupyter Packaging Utilities";
    homepage = "https://github.com/jupyter/jupyter-packaging";
    license = lib.licenses.bsd3;
  };
}
