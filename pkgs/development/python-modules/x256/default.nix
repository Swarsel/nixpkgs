{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "x256";
  version = "0.0.3";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-+FXbzNkeU/WJAoPYIDhVdDgn5+7VldXPGVRLo9IS4AE=";
  };

  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "x256" ];

  meta = {
    description = "Find the nearest xterm 256 color index for an RGB";
    homepage = "https://github.com/magarcia/python-x256";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Scriptkiddi ];
  };
})
