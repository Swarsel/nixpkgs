{
  lib,
  buildPythonPackage,
  fetchPypi,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pymorphy2-dicts-ru";
  version = "2.4.417127.4579844";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-eMrQOtymBQIavTh6Oy61FchRuG6UaCoe8jVKLHT8wZY=";
  };

  # has no tests
  doCheck = false;

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "pymorphy2_dicts_ru" ];

  meta = {
    description = "Russian dictionaries for pymorphy2";
    homepage = "https://github.com/kmike/pymorphy2-dicts/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
