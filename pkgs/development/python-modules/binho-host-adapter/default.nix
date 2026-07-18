{
  lib,
  buildPythonPackage,
  fetchPypi,
  pyserial,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "binho-host-adapter";
  version = "0.1.6";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-Hm2nqE4gjBO19IkGbwV3S/8dWT0PW/HKFJwrjoPq6FY=";
  };

  # Project has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ pyserial ];
  pyproject = true;
  pythonImportsCheck = [ "binhoHostAdapter" ];

  meta = {
    description = "Python library for Binho Multi-Protocol USB Host Adapters";
    homepage = "https://github.com/adafruit/Adafruit_Python_PlatformDetect";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
})
