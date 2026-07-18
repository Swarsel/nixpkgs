{
  # Evaluation
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # Dependencies
  gitpython,
  mkdocs,
  requests,
  # Build
  setuptools,
}:

buildPythonPackage rec {
  pname = "mkdocs-git-committers-plugin-2";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "ojacques";
    repo = "mkdocs-git-committers-plugin-2";
    tag = version;
    hash = "sha256-PpXgY5RlOeb0mB46gcNVWkSGMZa4WPkCwDUXMxCUjsI=";
  };

  # Upstream has no tests
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    gitpython
    mkdocs
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "mkdocs_git_committers_plugin_2" ];

  meta = {
    description = "MkDocs plugin for displaying a list of contributors on each page";
    homepage = "https://github.com/ojacques/mkdocs-git-committers-plugin-2";
    changelog = "https://github.com/ojacques/mkdocs-git-committers-plugin-2/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mahtaran ];
  };
}
