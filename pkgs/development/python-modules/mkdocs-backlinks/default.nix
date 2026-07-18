{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  mkdocs,
  setuptools,
}:

buildPythonPackage rec {
  pname = "mkdocs-backlinks";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "danodic-dev";
    repo = "mkdocs-backlinks";
    tag = "v${version}";
    hash = "sha256-P3CUm7jpmcgipn/SKpZMWhpEqJSpirADMpud10ULXDs=";
  };

  # No tests available
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    beautifulsoup4
    mkdocs
  ];

  pyproject = true;

  pythonImportsCheck = [
    "backlinks_plugin"
  ];

  meta = {
    description = "Plugin for adding backlinks to mkdocs";
    homepage = "https://github.com/danodic-dev/mkdocs-backlinks/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
