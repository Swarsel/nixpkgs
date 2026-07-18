{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  docopt,
  pytestCheckHook,
  pytz,
  requests,
  requests-mock,
  setuptools,
  syrupy,
  vincenty,
  xmltodict,
}:

buildPythonPackage rec {
  pname = "buienradar";
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = "mjj4791";
    repo = "python-buienradar";
    tag = version;
    hash = "sha256-DTdxzBe9fBOH5fHME++oq62xMtBKnjY7BCevwjl8VZ8=";
  };

  patches = [
    # https://github.com/mjj4791/python-buienradar/pull/26
    ./setuptools-82-compat.patch
  ];

  nativeCheckInputs = [
    pytestCheckHook
    requests-mock
    syrupy
  ];

  build-system = [ setuptools ];

  dependencies = [
    docopt
    pytz
    requests
    setuptools
    vincenty
    xmltodict
  ];

  disabledTests = [
    # require network connection
    "test_rain_data"
    "test_json_data"
    "test_xml_data"
    # tests fail if run on a different day
    "test_id_upper1"
    "test_invalid_data"
    "test_missing_data"
    "test_readdata1_30"
    "test_readdata1_60"
    "test_readdata2_30"
    "test_readdata2_60"
    "test_readdata3"
  ];

  pyproject = true;

  pytestFlags = [
    "--snapshot-warn-unused"
  ];

  pythonImportsCheck = [
    "buienradar.buienradar"
    "buienradar.constants"
  ];

  meta = {
    description = "Library and CLI tools for interacting with buienradar";
    homepage = "https://github.com/mjj4791/python-buienradar";
    changelog = "https://github.com/mjj4791/python-buienradar/blob/${src.tag}/CHANGLOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "buienradar";
  };
}
