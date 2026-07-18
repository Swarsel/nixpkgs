{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "openrgb-python";
  version = "0.3.6";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-86jy8hoOgQocdCeapjaRFO9PKx/TW9kcN16UKSWNVps=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "openrgb" ];

  meta = {
    description = "Module for the OpenRGB SDK";
    homepage = "https://openrgb-python.readthedocs.io/";
    changelog = "https://github.com/jath03/openrgb-python/releases/tag/v${version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}
