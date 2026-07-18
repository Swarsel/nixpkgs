{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:
let
  version = "2.2.0.20260508";
in
buildPythonPackage {
  inherit version;
  pname = "types-mysqlclient";

  src = fetchPypi {
    inherit version;
    hash = "sha256-DrNMz7yF4vf9V3JyNlGtKGPjayeHADO+/ka+crqfz+I=";
    pname = "types_mysqlclient";
  };

  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "MySQLdb-stubs" ];

  meta = {
    description = "Typing stubs for mysqlclient";
    homepage = "https://github.com/python/typeshed";
    changelog = "https://github.com/typeshed-internal/stub_uploader/blob/main/data/changelogs/mysqlclient.md";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.Nebucatnetzer ];
  };
}
