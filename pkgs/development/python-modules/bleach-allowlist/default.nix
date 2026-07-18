{
  lib,
  bleach,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "bleach-allowlist";
  version = "1.0.3";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-VuIghgeaDmoxAK6Z5NuvIOslhUhlmOsOmUAIoRQo2ps=";
  };

  # No tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ bleach ];
  pyproject = true;
  pythonImportsCheck = [ "bleach_allowlist" ];

  meta = {
    description = "Curated lists of tags and attributes for sanitizing html";
    homepage = "https://github.com/yourcelf/bleach-allowlist";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ ambroisie ];
  };
})
