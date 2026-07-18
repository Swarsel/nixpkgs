{
  lib,
  buildPythonPackage,
  fetchPypi,
  pycryptodome,
  python-kasa,
  requests,
  rtp,
  setuptools,
  urllib3,
}:

buildPythonPackage (finalAttrs: {
  pname = "pytapo";
  version = "3.4.15";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-2hC/MccVar7Xce5TL26qwVMrFQ+bxngiCitNx08Sz3E=";
  };

  # Tests require actual hardware
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    pycryptodome
    python-kasa
    requests
    rtp
    urllib3
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytapo" ];

  meta = {
    description = "Python library for communication with Tapo Cameras";
    homepage = "https://github.com/JurajNyiri/pytapo";
    changelog = "https://github.com/JurajNyiri/pytapo/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fleaz ];
  };
})
