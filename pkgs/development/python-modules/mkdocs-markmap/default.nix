{
  lib,
  fetchFromGitHub,
  attrs,
  beautifulsoup4,
  buildPythonPackage,
  mkdocs,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "mkdocs-markmap";
  version = "2.5.2";

  src = fetchFromGitHub {
    owner = "markmap";
    repo = "mkdocs_markmap";
    tag = "v${version}";
    hash = "sha256-jC0MgN0CM8VmUR9NYVM5P6J+f8Qplg1DDal7i246slM=";
  };

  # No tests available
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    attrs
    beautifulsoup4
    mkdocs
    requests
  ];

  pyproject = true;

  pythonImportsCheck = [
    "mkdocs_markmap"
  ];

  meta = {
    description = "MkDocs plugin and extension to create mindmaps from markdown using markmap";
    homepage = "https://github.com/markmap/mkdocs_markmap";
    changelog = "https://github.com/markmap/mkdocs_markmap/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
