{
  lib,
  aiodns,
  buildPythonPackage,
  c-ares,
  cffi,
  cmake,
  fetchPypi,
  idna,
  setuptools,
  tornado,
}:

buildPythonPackage (finalAttrs: {
  pname = "pycares";
  version = "5.0.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-WjwknIMEMmMUOYFfmoGEY0FvKoy9semI54dX3prnUIE=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ c-ares ];
  # Requires network access
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    cffi
    idna
  ];

  dontUseCmakeConfigure = true;
  propagatedNativeBuildInputs = [ cffi ];
  pyproject = true;
  pythonImportsCheck = [ "pycares" ];

  passthru.tests = {
    inherit aiodns tornado;
  };

  meta = {
    description = "Python interface for c-ares";
    homepage = "https://github.com/saghul/pycares";
    changelog = "https://github.com/saghul/pycares/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
