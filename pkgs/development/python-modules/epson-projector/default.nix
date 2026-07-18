{
  lib,
  aiohttp,
  buildPythonPackage,
  fetchPypi,
  pyserial-asyncio-fast,
  setuptools,
}:

buildPythonPackage rec {
  pname = "epson-projector";
  version = "0.6.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-/9Nc3xOxnXFfTsS8s83MXTkVAhqLwrKnmfR/E87s+Bk=";
    pname = "epson_projector";
  };

  # tests need real device
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    pyserial-asyncio-fast
  ];

  pyproject = true;

  pythonImportsCheck = [
    "epson_projector"
    "epson_projector.const"
    "epson_projector.projector_http"
    "epson_projector.projector_serial"
    "epson_projector.projector_tcp"
  ];

  meta = {
    description = "Epson projector support for Python";
    homepage = "https://github.com/pszafer/epson_projector";
    changelog = "https://github.com/pszafer/epson_projector/releases/tag/v.${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
