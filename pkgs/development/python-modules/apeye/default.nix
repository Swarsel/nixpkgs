{
  lib,
  apeye-core,
  buildPythonPackage,
  domdf-python-tools,
  fetchPypi,
  flit-core,
  platformdirs,
  requests,
}:
buildPythonPackage rec {
  pname = "apeye";
  version = "1.4.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-FOpUL61onjv9vaIYmjVKSQjpCu5L+EwVq3XWhFPXajY=";
    pname = "apeye";
  };

  build-system = [ flit-core ];

  dependencies = [
    apeye-core
    domdf-python-tools
    platformdirs
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "apeye" ];

  meta = {
    description = "Handy tools for working with URLs and APIs";
    homepage = "https://github.com/domdfcoding/apeye";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
  };
}
