{
  lib,
  fetchFromGitHub,
  anyio,
  asyncclick,
  bleak,
  bleak-retry-connector,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
  uv-dynamic-versioning,
}:

buildPythonPackage rec {
  pname = "togrill-bluetooth";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "elupus";
    repo = "togrill-bluetooth";
    tag = version;
    hash = "sha256-UZul5JEGv0zRcnUsEH2dkIiFt7jNYAc+9RvmDJMxkk0=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    hatchling
    uv-dynamic-versioning
  ];

  dependencies = [
    bleak
    bleak-retry-connector
  ];

  optional-dependencies = {
    cli = [
      anyio
      asyncclick
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "togrill_bluetooth" ];

  meta = {
    description = "Module to handle communication with ToGrill compatible temperature probes";
    homepage = "https://github.com/elupus/togrill-bluetooth";
    changelog = "https://github.com/elupus/togrill-bluetooth/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
    mainProgram = "togrill-bluetooth";
  };
}
