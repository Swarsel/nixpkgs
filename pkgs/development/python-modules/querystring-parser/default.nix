{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "querystring-parser";
  version = "1.2.4";

  src = fetchPypi {
    inherit version;
    hash = "sha256-ZE/OHP/gUwRTtDqDo4CU2+QizLqMmy8qHAAoDhTKimI=";
    pname = "querystring_parser";
  };

  # https://github.com/bernii/querystring-parser/issues/35
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ six ];
  pyproject = true;
  pythonImportsCheck = [ "querystring_parser" ];

  meta = {
    description = "Module to handle nested dictionaries";
    homepage = "https://github.com/bernii/querystring-parser";
    changelog = "https://github.com/bernii/querystring-parser/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
