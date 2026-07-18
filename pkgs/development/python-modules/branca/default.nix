{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jinja2,
  pytestCheckHook,
  selenium,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "branca";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "python-visualization";
    repo = "branca";
    tag = "v${version}";
    hash = "sha256-H5hHQI4r0QavygQZzEZAEp+cjra5R9m/OoGHQPtnBg0=";
  };

  postPatch = ''
    # We don't want flake8
    rm setup.cfg
  '';

  nativeCheckInputs = [
    pytestCheckHook
    selenium
  ];

  build-system = [ setuptools-scm ];
  dependencies = [ jinja2 ];

  disabledTestPaths = [
    # Some tests require a browser
    "tests/test_utilities.py"
    "tests/test_iframe.py"
  ];

  disabledTests = [
    "test_rendering_utf8_iframe"
    "test_rendering_figure_notebook"
  ];

  pyproject = true;
  pythonImportsCheck = [ "branca" ];

  meta = {
    description = "Generate complex HTML+JS pages with Python";
    homepage = "https://github.com/python-visualization/branca";
    changelog = "https://github.com/python-visualization/branca/blob/${src.tag}/CHANGES.txt";
    license = with lib.licenses; [ mit ];
    maintainers = [ ];
  };
}
