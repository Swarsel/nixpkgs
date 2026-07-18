{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  protobuf,
  pytest-mock,
  pytestCheckHook,
  setuptools,
  uplink,
}:

buildPythonPackage rec {
  pname = "uplink-protobuf";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "prkumar";
    repo = "uplink-protobuf";
    tag = "v${version}";
    hash = "sha256-HeA5bGmYSysidhz8YbST0uTqZ9BKFYQENrWuhcUZ7qY=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-mock
  ];

  build-system = [ setuptools ];

  dependencies = [
    uplink
    protobuf
  ];

  pyproject = true;
  pythonImportsCheck = [ "uplink_protobuf" ];

  meta = {
    description = "Protocol Buffers (Protobuf) support for Uplink";
    homepage = "https://github.com/prkumar/uplink-protobuf";
    changelog = "https://github.com/prkumar/uplink-protobuf/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
