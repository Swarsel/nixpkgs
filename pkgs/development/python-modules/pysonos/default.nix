{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ifaddr,
  isPy3k,
  mock,
  # Test dependencies
  pytestCheckHook,
  requests,
  requests-mock,
  xmltodict,
}:

buildPythonPackage rec {
  pname = "pysonos";
  version = "0.0.54";

  # pypi package is missing test fixtures
  src = fetchFromGitHub {
    owner = "amelchio";
    repo = "pysonos";
    rev = "v${version}";
    hash = "sha256-gBOknYHL5nQWFVhCbLN0Ah+1fovcNY4P2myryZnUadk=";
  };

  propagatedBuildInputs = [
    ifaddr
    requests
    xmltodict
  ];

  nativeCheckInputs = [
    pytestCheckHook
    mock
    requests-mock
  ];

  disabled = !isPy3k;

  disabledTests = [
    "test_desc_from_uri" # test requires network access
  ];

  format = "setuptools";

  meta = {
    description = "SoCo fork with fixes for Home Assistant";
    homepage = "https://github.com/amelchio/pysonos";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ juaningan ];
  };
}
