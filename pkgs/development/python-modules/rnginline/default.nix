{
  lib,
  buildPythonPackage,
  docopt-ng,
  fetchPypi,
  importlib-metadata,
  importlib-resources,
  lxml,
  mock,
  poetry-core,
  pytestCheckHook,
  pythonAtLeast,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "rnginline";
  version = "1.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-JWqzs+OqOynIAWYVgGrZiuiCqObAgGe6rBt0DcP3U6E=";
  };

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    docopt-ng
    lxml
    typing-extensions
    importlib-metadata
    importlib-resources
  ];

  disabledTests = lib.optionals (pythonAtLeast "3.14") [
    # pathname2url now emits RFC 1738 authority-prefixed file URLs for absolute paths
    "test_file_url_roundtrip"
  ];

  pyproject = true;
  pythonImportsCheck = [ "rnginline" ];

  pythonRelaxDeps = [
    "docopt-ng"
    "importlib-metadata"
    "lxml"
  ];

  meta = {
    description = "Python library and command-line tool for loading multi-file RELAX NG schemas from arbitary URLs, and flattening them into a single RELAX NG schema";
    homepage = "https://github.com/h4l/rnginline";
    changelog = "https://github.com/h4l/rnginline/blob/${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ lesuisse ];
  };
}
