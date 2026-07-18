{
  lib,
  fetchFromGitHub,
  bleak,
  bleak-retry-connector,
  buildPythonPackage,
  construct-typing,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "eq3btsmart";
  version = "2.4.2";

  src = fetchFromGitHub {
    owner = "EuleMitKeule";
    repo = "eq3btsmart";
    tag = version;
    hash = "sha256-jIQWh7z2bDwWXfirtIThVYUDvgaEMLoMumR4u3rnZ/0=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    bleak
    bleak-retry-connector
    construct-typing
  ];

  pyproject = true;
  pythonImportsCheck = [ "eq3btsmart" ];

  meta = {
    description = "Python library that allows interaction with eQ-3 Bluetooth smart thermostats";
    homepage = "https://github.com/EuleMitKeule/eq3btsmart";
    changelog = "https://github.com/EuleMitKeule/eq3btsmart/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
