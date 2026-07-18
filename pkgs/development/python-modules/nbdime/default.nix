{
  lib,
  stdenv,
  buildPythonPackage,
  # dependencies
  colorama,
  fetchPypi,
  # tests
  gitMinimal,
  gitpython,
  # build-system
  hatch-jupyter-builder,
  hatchling,
  jinja2,
  jupyter-server,
  jupyterlab,
  nbformat,
  pygments,
  pytestCheckHook,
  requests,
  tornado,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "nbdime";
  version = "4.0.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-jNJez+61EF1WMjfX9k60dIBY+6m7qas4kqH/YeF3zhY=";
  };

  nativeCheckInputs = [
    gitMinimal
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  preCheck = ''
    git config --global user.email "janedoe@example.com"
    git config --global user.name "Jane Doe"
  '';

  __darwinAllowLocalNetworking = true;

  build-system = [
    hatch-jupyter-builder
    hatchling
    jupyterlab
  ];

  dependencies = [
    colorama
    gitpython
    jinja2
    jupyter-server
    nbformat
    pygments
    requests
    tornado
  ];

  disabledTests = [
    # subprocess.CalledProcessError: Command '['git', 'diff', 'base', 'diff.ipynb']' returned non-zero exit status 128.
    # git-nbdiffdriver diff: line 1: git-nbdiffdriver: command not found
    # fatal: external diff died, stopping at diff.ipynb
    "test_git_diffdriver"

    # subprocess.CalledProcessError: Command '['git', 'merge', 'remote-no-conflict']' returned non-zero exit status 1.
    "test_git_mergedriver"

    # Require network access
    "test_git_difftool"
    "test_git_mergetool"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # OSError: Could not find system gitattributes location!
    "test_locate_gitattributes_syste"
  ];

  pyproject = true;
  pythonImportsCheck = [ "nbdime" ];

  meta = {
    description = "Tools for diffing and merging of Jupyter notebooks";
    homepage = "https://github.com/jupyter/nbdime";
    changelog = "https://github.com/jupyter/nbdime/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
