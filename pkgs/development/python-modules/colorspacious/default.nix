{
  lib,
  buildPythonPackage,
  fetchPypi,
  numpy,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "colorspacious";
  version = "1.1.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-XpBy6M3KiJ2sRFw1yTYqIsz3WOl7ALef8NWnuj4Rthg=";
  };

  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "colorspacious" ];

  meta = {
    description = "Powerful, accurate, and easy-to-use Python library for doing colorspace conversions";
    homepage = "https://github.com/njsmith/colorspacious";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
