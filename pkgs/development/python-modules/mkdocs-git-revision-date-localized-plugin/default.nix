{
  lib,
  fetchFromGitHub,
  babel,
  buildPythonPackage,
  gitpython,
  mkdocs,
  pytestCheckHook,
  pytz,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "mkdocs-git-revision-date-localized-plugin";
  version = "1.5.3";

  src = fetchFromGitHub {
    owner = "timvink";
    repo = "mkdocs-git-revision-date-localized-plugin";
    tag = "v${version}";
    hash = "sha256-Fk8xh40uQY15iCkDY/0y0y4hMAHo07cfLXL1ZyFp30w=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    babel
    gitpython
    mkdocs
    pytz
  ];

  disabledTestPaths = [ "tests/test_builds.py" ];
  pyproject = true;
  pythonImportsCheck = [ "mkdocs_git_revision_date_localized_plugin" ];

  meta = {
    description = "MkDocs plugin that enables displaying the date of the last git modification of a page";
    homepage = "https://github.com/timvink/mkdocs-git-revision-date-localized-plugin";
    changelog = "https://github.com/timvink/mkdocs-git-revision-date-localized-plugin/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ totoroot ];
  };
}
