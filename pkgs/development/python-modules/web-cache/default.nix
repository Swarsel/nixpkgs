{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPy3k,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "web-cache";
  version = "1.1.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-1aEKNMh77/x5S44d7He/a0GYhrnMYLmxDHBoEIcODrU=";
    pname = "web_cache";
  };

  # No tests in downloaded archive
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  disabled = !isPy3k;
  pyproject = true;
  pythonImportsCheck = [ "web_cache" ];

  meta = {
    description = "Simple Python key-value storage backed up by sqlite3 database";
    homepage = "https://github.com/desbma/web_cache";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ moni ];
  };
})
