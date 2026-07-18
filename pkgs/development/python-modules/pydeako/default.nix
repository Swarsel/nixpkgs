{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mock,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  zeroconf,
}:

buildPythonPackage rec {
  pname = "pydeako";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "DeakoLights";
    repo = "pydeako";
    tag = version;
    hash = "sha256-GEYuVKE3DOXJzCqTW2Ngoi6l0e4JvE9lUnZtjrNXTVk=";
  };

  # Module has no tests
  #doCheck = false;
  nativeCheckInputs = [
    mock
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ zeroconf ];
  pyproject = true;
  pythonImportsCheck = [ "pydeako" ];

  meta = {
    description = "Module used to discover and communicate with Deako devices over the network locally";
    homepage = "https://github.com/DeakoLights/pydeako";
    changelog = "https://github.com/DeakoLights/pydeako/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
