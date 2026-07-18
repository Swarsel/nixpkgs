{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dateparser,
  defusedxml,
  importlib-metadata,
  numpy,
  pytestCheckHook,
  python-dateutil,
  pytz,
  remotezip,
  requests,
  requests-mock,
  setuptools-scm,
  shapely,
  tenacity,
}:

buildPythonPackage rec {
  pname = "asf-search";
  version = "11.0.0";

  src = fetchFromGitHub {
    owner = "asfadmin";
    repo = "Discovery-asf_search";
    tag = "v${version}";
    hash = "sha256-Z6DZOjXpziCAn9ZqbRa1c0cAVAbPEt5Go63BlA4Umog=";
  };

  nativeCheckInputs = [
    defusedxml
    pytestCheckHook
    requests-mock
    tenacity
  ];

  build-system = [ setuptools-scm ];

  dependencies = [
    dateparser
    importlib-metadata
    numpy
    python-dateutil
    pytz
    remotezip
    requests
    shapely
  ];

  disabledTestPaths = [
    # requires asf_enumeration, not packaged
    "tests/BaselineSearch/test_baseline_search.py"
    # requires network
    "tests/Pair/test_Pair.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "asf_search" ];
  pythonRelaxDeps = [ "tenacity" ];

  meta = {
    description = "Python wrapper for the ASF SearchAPI";
    homepage = "https://github.com/asfadmin/Discovery-asf_search";
    changelog = "https://github.com/asfadmin/Discovery-asf_search/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ bzizou ];
  };
}
