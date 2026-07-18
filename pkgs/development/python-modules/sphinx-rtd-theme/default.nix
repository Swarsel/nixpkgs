{
  lib,
  buildPythonPackage,
  docutils,
  fetchPypi,
  pytestCheckHook,
  setuptools,
  sphinx,
  sphinxcontrib-jquery,
}:

buildPythonPackage rec {
  pname = "sphinx-rtd-theme";
  version = "3.1.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-tEJ28sJ26Qkjmk9slVqmZ6qv63hZeSOxxgurx223jkw=";
    pname = "sphinx_rtd_theme";
  };

  preBuild = ''
    # Don't use npm to fetch assets. Assets are included in sdist.
    export CI=1
  '';

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    docutils
    sphinx
    sphinxcontrib-jquery
  ];

  disabledTests = [
    # docutils 0.21 compat
    "test_basic"
  ];

  pyproject = true;
  pythonImportsCheck = [ "sphinx_rtd_theme" ];

  pythonRelaxDeps = [
    "docutils"
    "sphinxcontrib-jquery"
    # https://github.com/readthedocs/sphinx_rtd_theme/pull/1666
    "sphinx"
  ];

  meta = {
    description = "Sphinx theme for readthedocs.org";
    homepage = "https://github.com/readthedocs/sphinx_rtd_theme";
    changelog = "https://github.com/readthedocs/sphinx_rtd_theme/blob/${version}/docs/changelog.rst";
    license = lib.licenses.mit;
  };
}
