{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cli-helpers,
  click,
  configobj,
  prompt-toolkit,
  pygments,
  setuptools,
  setuptools-scm,
  sqlparse,
}:

buildPythonPackage rec {
  pname = "litecli";
  version = "1.17.1";

  src = fetchFromGitHub {
    owner = "dbcli";
    repo = "litecli";
    tag = "v${version}";
    hash = "sha256-YSPNtDL5rNgRh5lJBKfL1jjWemlmf3eesBMSLyJVRLY=";
  };

  doCheck = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    click
    pygments
    prompt-toolkit
    sqlparse
    configobj
    cli-helpers
  ];

  pyproject = true;

  pythonImportsCheck = [
    "litecli"
  ];

  meta = {
    description = "CLI for SQLite Databases with auto-completion and syntax highlighting";
    homepage = "https://github.com/dbcli/litecli";
    changelog = "https://github.com/dbcli/litecli/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ nullstring1 ];
    mainProgram = "litecli";
  };
}
