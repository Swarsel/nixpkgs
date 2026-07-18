{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  sphinx,
}:

buildPythonPackage rec {
  pname = "sphinxext-rediraffe";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "wpilibsuite";
    repo = "sphinxext-rediraffe";
    tag = "v${version}";
    hash = "sha256-OW+MNQbPfJa8+jcpWZxTKD+EAv1gyo5tmcYAGba4u3c=";
  };

  # tests require seleniumbase which is not currently in nixpkgs
  doCheck = false;
  build-system = [ flit-core ];

  dependencies = [
    sphinx
  ];

  pyproject = true;
  pythonImportsCheck = [ "sphinxext.rediraffe" ];
  pythonNamespaces = [ "sphinxext" ];

  meta = {
    description = "Sphinx extension to redirect files";
    homepage = "https://github.com/wpilibsuite/sphinxext-rediraffe";
    changelog = "https://github.com/wpilibsuite/sphinxext-rediraffe/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.newam ];
  };
}
