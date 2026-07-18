{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyserial-asyncio-fast,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyotgw";
  version = "2.2.3";

  src = fetchFromGitHub {
    owner = "mvn23";
    repo = "pyotgw";
    tag = finalAttrs.version;
    hash = "sha256-0F+UBIPk+A9z0YJtLVlJAqzMre8GZAio720SCi2dorE=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ pyserial-asyncio-fast ];

  disabledTests = [
    # Tests require network access
    "connect_timeouterror"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyotgw" ];

  meta = {
    description = "Python module to interact the OpenTherm Gateway";
    homepage = "https://github.com/mvn23/pyotgw";
    changelog = "https://github.com/mvn23/pyotgw/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ fab ];
  };
})
