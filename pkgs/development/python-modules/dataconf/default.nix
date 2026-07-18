{
  lib,
  buildPythonPackage,
  fetchPypi,
  isodate,
  poetry-core,
  pyhocon,
  pyparsing,
  python-dateutil,
  pyyaml,
}:
let
  pname = "dataconf";
  version = "3.6.0";
in
buildPythonPackage {
  inherit pname version;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-hcZi8n290GZkgIM074Z1Ne2gOS5WDmX8fPR+BJGZyzU=";
  };

  build-system = [ poetry-core ];

  dependencies = [
    isodate
    pyhocon
    pyparsing
    python-dateutil
    pyyaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "dataconf" ];

  meta = {
    description = "Simple dataclasses configuration management for Python with hocon/json/yaml/properties/env-vars/dict/cli support";
    homepage = "https://github.com/zifeo/dataconf";
    changelog = "https://github.com/zifeo/dataconf/blob/main/CHANGELOG.md";
    license = lib.licenses.mpl20;
    maintainers = [ lib.maintainers.Nebucatnetzer ];
  };
}
