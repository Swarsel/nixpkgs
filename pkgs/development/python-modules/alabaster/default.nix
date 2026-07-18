{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
}:

buildPythonPackage rec {
  pname = "alabaster";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "sphinx-doc";
    repo = "alabaster";
    tag = version;
    hash = "sha256-aQEhFZUJs0TptfpjQVoIVI9V9a+xKjE2OfStSaJKHGI=";
  };

  # No tests included
  doCheck = false;
  build-system = [ flit-core ];
  pyproject = true;
  pythonImportsCheck = [ "alabaster" ];

  meta = {
    description = "Light, configurable Sphinx theme";
    homepage = "https://github.com/sphinx-doc/alabaster";
    changelog = "https://github.com/sphinx-doc/alabaster/blob/${src.rev}/docs/changelog.rst";
    license = lib.licenses.bsd3;
  };
}
