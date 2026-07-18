{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  toml,
}:

buildPythonPackage rec {
  pname = "confight";
  version = "2.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-iodoexnh9tG4dgkjDXCUzWRFDhRlJ3HRgaNhxG2lwPY=";
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ toml ];
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "confight" ];

  meta = {
    description = "Python context manager for managing pid files";
    homepage = "https://github.com/avature/confight";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ mkg20001 ];
    mainProgram = "confight";
  };
}
