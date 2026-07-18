{
  lib,
  blessed,
  browser-cookie3,
  buildPythonPackage,
  cloudscraper,
  fetchPypi,
  keyring,
  keyrings-alt,
  lxml,
  measurement,
  mock,
  pytestCheckHook,
  python-dateutil,
  requests,
  rich,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "myfitnesspal";
  version = "2.1.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-eE807M8qFDlSMAcE+GFJyve1YfmlWmB3ML9VJhMUeIE=";
  };

  postPatch = ''
    # Remove overly restrictive version constraints
    sed -i -e "s/>=.*//" requirements.txt

    # https://github.com/coddingtonbear/python-measurement/pull/8
    substituteInPlace tests/test_client.py \
      --replace-fail "Weight" "Mass" \
      --replace-fail '"Mass"' '"Weight"'
  '';

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    blessed
    browser-cookie3
    cloudscraper
    keyring
    keyrings-alt
    lxml
    measurement
    python-dateutil
    requests
    rich
    typing-extensions
  ];

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ];

  disabledTests = [
    # Integration tests require an account to be set
    "test_integration"
  ];

  pyproject = true;
  pythonImportsCheck = [ "myfitnesspal" ];
  pythonRelaxDeps = [ "typing-extensions" ];

  meta = {
    description = "Python module to access meal tracking data stored in MyFitnessPal";
    homepage = "https://github.com/coddingtonbear/python-myfitnesspal";
    license = lib.licenses.mit;
    mainProgram = "myfitnesspal";
  };
}
