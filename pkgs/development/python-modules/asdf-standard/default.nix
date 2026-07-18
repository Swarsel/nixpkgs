{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "asdf-standard";
  version = "1.5.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-WULK99FD859y9jRIQ3PH9AzkhXHR2zwnHhOFjjP+WWY=";
    pname = "asdf_standard";
  };

  # Circular dependency on asdf
  doCheck = false;
  build-system = [ setuptools-scm ];
  pyproject = true;
  pythonImportsCheck = [ "asdf_standard" ];

  meta = {
    description = "Standards document describing ASDF";
    homepage = "https://github.com/asdf-format/asdf-standard";
    changelog = "https://github.com/asdf-format/asdf-standard/releases/tag/${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
  };
}
