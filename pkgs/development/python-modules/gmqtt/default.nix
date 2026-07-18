{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytest-asyncio,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "gmqtt";
  version = "0.7.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-vt/se6wmtrTOHwxMMs/z1mNSalTIgtMj1BVg/DubRKI=";
  };

  # Tests require local socket connection which is forbidden in the sandbox
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "gmqtt" ];

  meta = {
    description = "Python MQTT v5.0 async client";
    homepage = "https://github.com/wialon/gmqtt";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
