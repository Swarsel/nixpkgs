{
  lib,
  fetchFromGitHub,
  aiohttp,
  asyncstdlib,
  buildPythonPackage,
  dataclasses-json,
  pytest-cov-stub,
  pytest-mock,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "meteoswiss-async";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "albertomontesg";
    repo = "meteoswiss-async";
    tag = version;
    hash = "sha256-xFvfyLZvBfnbzShKN+94piNUVjV1cfi4jWpc/Xw6XG4=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-mock
    pytest-cov-stub
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    asyncstdlib
    dataclasses-json
  ];

  pyproject = true;
  pythonImportsCheck = [ "meteoswiss_async" ];

  pythonRelaxDeps = [
    "aiohttp"
    "asyncstdlib"
  ];

  meta = {
    description = "Asynchronous client library for MeteoSwiss API";
    homepage = "https://github.com/albertomontesg/meteoswiss-async";
    changelog = "https://github.com/albertomontesg/meteoswiss-async/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
