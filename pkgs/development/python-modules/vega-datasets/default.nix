{
  lib,
  buildPythonPackage,
  fetchPypi,
  pandas,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "vega-datasets";
  version = "0.9.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-nb6YNCCOjsMqtElw3zFd6RAoYeTNoT2OFDqreoDZP8A=";
    pname = "vega_datasets";
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ pandas ];
  nativeCheckInputs = [ pytestCheckHook ];

  disabledTests = [
    # timestamp precision mismatch
    "test_date_types"
    "test_stock_date_parsing"
  ];

  pyproject = true;
  pytestFlags = [ "--doctest-modules" ];
  pythonImportsCheck = [ "vega_datasets" ];

  meta =
    let
      tag = lib.removeSuffix ".0" "v${version}";
    in
    {
      description = "Python package for offline access to vega datasets";
      homepage = "https://github.com/altair-viz/vega_datasets";
      changelog = "https://github.com/altair-viz/vega_datasets/blob/${tag}/CHANGES.md";
      license = lib.licenses.mit;
    };
}
