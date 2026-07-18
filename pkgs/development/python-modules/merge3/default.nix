{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "merge3";
  version = "0.0.16";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-CFLeQ4HLRr5e9O1J46wgxaSgzUao/0u7hwvCeqtUMwY=";
  };

  nativeBuildInputs = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "merge3" ];

  meta = {
    description = "Python implementation of 3-way merge";
    homepage = "https://github.com/breezy-team/merge3";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    mainProgram = "merge3";
  };
}
