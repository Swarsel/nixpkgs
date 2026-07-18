{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "durus";
  version = "4.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-aQM0I26juo2WbjrszgJUd5CdayQNCzID0zJ/YkNyYAc=";
  };

  # Checks disabled due to missing python unittest framework 'sancho' in nixpkgs
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;

  pythonImportsCheck = [
    "durus.connection"
    "durus.file_storage"
    "durus.client_storage"
    "durus.sqlite_storage"
  ];

  meta = {
    description = "Object persistence layer";
    homepage = "https://github.com/nascheme/durus";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ grindhold ];
    mainProgram = "durus";
  };
}
