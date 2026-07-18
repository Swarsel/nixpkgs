{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatchling,
  # dependencies
  msgpack,
  # tests
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "fluent-logger";
  version = "0.11.1";

  src = fetchFromGitHub {
    owner = "fluent";
    repo = "fluent-logger-python";
    tag = "v${version}";
    hash = "sha256-i6S5S2ZUwC5gQPdVjefUXrKj43iLIqxd8tdXbMBJNnA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];
  dependencies = [ msgpack ];
  pyproject = true;

  pythonImportsCheck = [
    "fluent"
    "fluent.event"
    "fluent.handler"
    "fluent.sender"
  ];

  meta = {
    description = "Structured logger for Fluentd (Python)";
    homepage = "https://github.com/fluent/fluent-logger-python";
    license = lib.licenses.asl20;
  };
}
