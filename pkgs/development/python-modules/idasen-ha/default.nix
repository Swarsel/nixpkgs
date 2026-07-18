{
  lib,
  fetchFromGitHub,
  bleak-retry-connector,
  buildPythonPackage,
  idasen,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "idasen-ha";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "abmantis";
    repo = "idasen-ha";
    tag = version;
    hash = "sha256-1BciJ3Hox9Ky1HuNw+8jWGaMX3amAhGNTGAXqwWEDX8=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    bleak-retry-connector
    idasen
  ];

  pyproject = true;
  pythonImportsCheck = [ "idasen_ha" ];

  meta = {
    description = "Home Assistant helper lib for the IKEA Idasen Desk integration";
    homepage = "https://github.com/abmantis/idasen-ha";
    changelog = "https://github.com/abmantis/idasen-ha/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
