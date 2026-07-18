{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  docker,
  python-vagrant,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "molecule-plugins";
  version = "25.8.12";

  src = fetchFromGitHub {
    owner = "ansible-community";
    repo = "molecule-plugins";
    tag = "v${version}";
    hash = "sha256-wTvJ+cjZMTOyaqqDZsA1wsKCpu2FEi69IBlSTxNs3/M=";
  };

  nativeBuildInputs = [
    setuptools-scm
  ];

  # Tests require container runtimes
  doCheck = false;

  optional-dependencies = {
    docker = [ docker ];
    vagrant = [ python-vagrant ];
  };

  pyproject = true;
  pythonImportsCheck = [ "molecule_plugins" ];
  # reverse the dependency
  pythonRemoveDeps = [ "molecule" ];

  meta = {
    description = "Collection on molecule plugins";
    homepage = "https://github.com/ansible-community/molecule-plugins";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
