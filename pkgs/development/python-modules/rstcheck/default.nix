{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  rstcheck-core,
  setuptools,
  setuptools-scm,
  sphinx,
  typer,
}:

buildPythonPackage rec {
  pname = "rstcheck";
  version = "6.2.5";

  src = fetchFromGitHub {
    owner = "rstcheck";
    repo = "rstcheck";
    tag = "v${version}";
    hash = "sha256-ajevEHCsPvr5e4K8I5AfxFZ+Vo1quaGUKFIEB9Wlobc=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    # The tests need to find and call the rstcheck executable
    export PATH="$PATH:$out/bin";
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    rstcheck-core
    typer
  ];

  optional-dependencies = {
    sphinx = [ sphinx ];
  };

  pyproject = true;
  pythonImportsCheck = [ "rstcheck" ];

  meta = {
    description = "Checks syntax of reStructuredText and code blocks nested within it";
    homepage = "https://github.com/myint/rstcheck";
    changelog = "https://github.com/rstcheck/rstcheck/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ staccato ];
    mainProgram = "rstcheck";
  };
}
