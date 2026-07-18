{
  lib,
  buildPythonPackage,
  cryptography,
  fetchPypi,
  grequests,
  hatchling,
  hawkauthlib,
  mock,
  parameterized,
  pybrowserid,
  pyjwt,
  pytestCheckHook,
  requests,
  responses,
}:

buildPythonPackage rec {
  pname = "pyfxa";
  version = "0.8.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-gq/OfpKjw6BSbGKTXbRa2crxleJJoj0BN4Ful1npWlw=";
  };

  nativeCheckInputs = [
    grequests
    mock
    responses
    pytestCheckHook
    parameterized
  ];

  build-system = [ hatchling ];

  dependencies = [
    cryptography
    hawkauthlib
    pybrowserid
    pyjwt
    requests
  ];

  disabledTestPaths = [
    # Requires network access
    "fxa/tests/test_core.py"
    "fxa/tests/test_oauth.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "fxa" ];

  meta = {
    description = "Firefox Accounts client library";
    homepage = "https://github.com/mozilla/PyFxA";
    license = lib.licenses.mpl20;
    maintainers = [ ];
    mainProgram = "fxa-client";
  };
}
