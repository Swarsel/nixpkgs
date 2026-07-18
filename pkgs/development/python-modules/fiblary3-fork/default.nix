{
  lib,
  buildPythonPackage,
  fetchPypi,
  fixtures,
  jsonpatch,
  netaddr,
  prettytable,
  pytestCheckHook,
  python-dateutil,
  requests,
  requests-mock,
  six,
  testtools,
}:

buildPythonPackage rec {
  pname = "fiblary3-fork";
  version = "0.1.12";

  src = fetchPypi {
    inherit pname version;
    sha256 = "001wqh7gx2dv3sf7a5xsbppz9r88f5qwrp05jzjsjcm6cbcvmsz0";
  };

  propagatedBuildInputs = [
    jsonpatch
    netaddr
    prettytable
    python-dateutil
    requests
    six
  ];

  nativeCheckInputs = [
    fixtures
    pytestCheckHook
    requests-mock
    testtools
  ];

  format = "setuptools";
  pythonImportsCheck = [ "fiblary3" ];

  meta = {
    description = "Fibaro Home Center API Python Library";
    homepage = "https://github.com/graham33/fiblary";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ graham33 ];
  };
}
