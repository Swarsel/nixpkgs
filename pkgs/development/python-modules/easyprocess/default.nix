{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAtrrs: {
  pname = "easyprocess";
  version = "1.1";

  src = fetchPypi {
    inherit (finalAtrrs) version;
    hash = "sha256-iFiYMCpXqrlIlz6LXTKkIpOSufstmGqx1P/VkOW6kOw=";
    pname = "EasyProcess";
  };

  # No tests
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  pyproject = true;

  meta = {
    description = "Easy to use python subprocess interface";
    homepage = "https://github.com/ponty/EasyProcess";
    license = lib.licenses.bsdOriginal;
    maintainers = with lib.maintainers; [ layus ];
  };
})
