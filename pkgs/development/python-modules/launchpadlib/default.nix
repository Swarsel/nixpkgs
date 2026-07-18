{
  lib,
  buildPythonPackage,
  fetchPypi,
  httplib2,
  lazr-restfulclient,
  lazr-uri,
  pytestCheckHook,
  setuptools_80,
  six,
  testresources,
}:

buildPythonPackage rec {
  pname = "launchpadlib";
  version = "2.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-tMJYkLt1BQ1UwIEj0nMxVreKWaJVX1Rh9psORM2RJC8=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    testresources
  ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  build-system = [ setuptools_80 ];

  dependencies = [
    httplib2
    lazr-restfulclient
    lazr-uri
    six
  ];

  pyproject = true;

  pythonImportsCheck = [
    "launchpadlib"
    "launchpadlib.apps"
    "launchpadlib.credentials"
  ];

  meta = {
    description = "Script Launchpad through its web services interfaces. Officially supported";
    homepage = "https://help.launchpad.net/API/launchpadlib";
    license = lib.licenses.lgpl3Only;
    maintainers = [ ];
  };
}
