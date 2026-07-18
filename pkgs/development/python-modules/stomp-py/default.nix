{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  docopt,
  # build-system
  poetry-core,
  # tests
  pytestCheckHook,
  websocket-client,
}:

buildPythonPackage rec {
  pname = "stomp-py";
  version = "8.2.0";

  src = fetchFromGitHub {
    owner = "jasonrbriggs";
    repo = "stomp.py";
    tag = "v${version}";
    hash = "sha256-UkNmE0+G9d3k1OhkNl98Jy5sP6MAywynzBmBtK9mZ90=";
  };

  doCheck = false; # needs external services setup

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    poetry-core
  ];

  dependencies = [
    docopt
    websocket-client
  ];

  pyproject = true;
  pythonImportsCheck = [ "stomp" ];

  meta = {
    description = "Client library for accessing messaging servers (such as ActiveMQ or RabbitMQ) using the STOMP protocol";
    homepage = "https://github.com/jasonrbriggs/stomp.py";
    changelog = "https://github.com/jasonrbriggs/stomp.py/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ veprbl ];
  };
}
