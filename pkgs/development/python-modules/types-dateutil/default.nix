{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "types-dateutil";
  version = "2.9.0.20241003";

  src = fetchPypi {
    inherit version;
    hash = "sha256-WMuFRJsqVtZoTkGu77TEKAYxJGoNoacZvb5vP7AxdEY=";
    pname = "types-python-dateutil";
  };

  nativeBuildInputs = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "dateutil-stubs" ];

  meta = {
    description = "Typing stubs for python-dateutil";
    homepage = "https://github.com/python/typeshed";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ milibopp ];
  };
}
