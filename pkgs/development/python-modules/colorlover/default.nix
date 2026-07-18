{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "colorlover";
  version = "0.3.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-uPtyRqtG4fXmcVZJRTwXYuJFpRXeX/LStKq3puZ/pOI=";
  };

  # no tests included in distributed archive
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "colorlover" ];

  meta = {
    description = "Color scales in Python for humans";
    homepage = "https://github.com/plotly/colorlover";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
