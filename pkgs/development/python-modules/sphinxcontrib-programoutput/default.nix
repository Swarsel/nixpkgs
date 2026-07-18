{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  sphinx,
}:

buildPythonPackage rec {
  pname = "sphinxcontrib-programoutput";
  version = "0.18";

  src = fetchFromGitHub {
    owner = "NextThought";
    repo = "sphinxcontrib-programoutput";
    tag = version;
    hash = "sha256-WI4R96G4cYYTxTwW4dKAayUNQyhVSrjhdWJyy8nZBUk=";
  };

  buildInputs = [ sphinx ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "sphinxcontrib.programoutput" ];
  pythonNamespaces = [ "sphinxcontrib" ];

  meta = {
    description = "Sphinx extension to include program output";
    homepage = "https://github.com/NextThought/sphinxcontrib-programoutput";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
}
