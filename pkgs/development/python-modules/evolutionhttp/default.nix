{
  lib,
  # dependencies
  aiofiles,
  aiohttp,
  buildPythonPackage,
  fetchPypi,
  # build-system
  hatchling,
  # tests
  mock,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "evolutionhttp";
  version = "0.0.19";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-VhWYhkrZVUDu1I6ZZTZlTUhNfpma29tEYBLoT7xBd1M=";
  };

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiofiles
    aiohttp
  ];

  pyproject = true;
  pythonImportsCheck = [ "evolutionhttp" ];

  meta = {
    description = "HTTP client for controlling a Bryant Evolution HVAC system";
    homepage = "https://github.com/danielsmyers/evolutionhttp";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
