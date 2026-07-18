{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dacite,
  freezegun,
  pysnmp,
  pytest-asyncio,
  pytest-error-for-skips,
  pytestCheckHook,
  pythonOlder,
  setuptools,
  syrupy,
}:

buildPythonPackage rec {
  pname = "brother";
  version = "6.1.1";

  src = fetchFromGitHub {
    owner = "bieniu";
    repo = "brother";
    tag = version;
    hash = "sha256-7m0fakQCckIpG8Tc09P81xzHlIgeal9L2BwerUvBuX8=";
  };

  nativeCheckInputs = [
    freezegun
    pytest-asyncio
    pytest-error-for-skips
    pytestCheckHook
    syrupy
  ];

  build-system = [ setuptools ];

  dependencies = [
    dacite
    pysnmp
  ];

  disabled = pythonOlder "3.12";
  pyproject = true;
  pythonImportsCheck = [ "brother" ];

  meta = {
    description = "Python wrapper for getting data from Brother laser and inkjet printers via SNMP";
    homepage = "https://github.com/bieniu/brother";
    changelog = "https://github.com/bieniu/brother/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
