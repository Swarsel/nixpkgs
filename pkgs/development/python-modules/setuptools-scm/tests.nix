{
  buildPythonPackage,
  git,
  mercurial,
  pip,
  pytestCheckHook,
  setuptools-scm,
  virtualenv,
}:

buildPythonPackage {
  inherit (setuptools-scm) version src;
  pname = "setuptools-scm-tests";

  nativeCheckInputs = [
    pytestCheckHook
    setuptools-scm
    pip
    virtualenv
    git
    mercurial
  ];

  disabledTests = [
    # network access
    "test_pip_download"
  ];

  dontBuild = true;
  dontInstall = true;
  pyproject = false;
}
