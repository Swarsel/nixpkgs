{
  lib,
  buildPythonPackage,
  chardet,
  fetchPypi,
  flit-core,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "encutils";
  version = "1.0.0";

  # pyproject.toml on GitHub uses coherent.build as build-system
  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-OOylrxjOur2L5DwX8UydP7uoPMX3rI46schuJMSyuRo=";
  };

  # expect chardet.detect to return None
  patches = [ ./chardet6-compat.patch ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ flit-core ];

  dependencies = [
    chardet
  ];

  pyproject = true;
  pythonImportsCheck = [ "encutils" ];

  meta = {
    description = "Collection of helper functions to detect encodings of text files";
    homepage = "https://github.com/coherent-oss/encutils";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ lib.maintainers.dotlambda ];
  };
})
