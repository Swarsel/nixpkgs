{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  pytest-rerunfailures,
  pytestCheckHook,
  vine,
}:

buildPythonPackage rec {
  pname = "amqp";
  version = "5.3.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-zdwAxyVElSICO62Un3D/97SPCxredNFwpvEKsERzlDI=";
  };

  propagatedBuildInputs = [ vine ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-rerunfailures
  ];

  __darwinAllowLocalNetworking = true;

  disabledTests = [
    # Requires network access
    "test_rmq.py"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Requires network access but fails on macos only
    "test_connection.py"
  ];

  format = "setuptools";
  pythonImportsCheck = [ "amqp" ];

  meta = {
    description = "Python client for the Advanced Message Queuing Procotol (AMQP). This is a fork of amqplib which is maintained by the Celery project";
    homepage = "https://github.com/celery/py-amqp";
    changelog = "https://github.com/celery/py-amqp/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
  };
}
