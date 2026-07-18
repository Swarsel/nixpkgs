{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  git,
  packaging,
  pytestCheckHook,
  setuptools,
  vcs-versioning,
}:

buildPythonPackage (finalAttrs: {
  pname = "vcs-versioning";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "pypa";
    repo = "setuptools-scm";
    tag = "vcs-versioning-v${finalAttrs.version}";
    hash = "sha256-CfRzupWFtvmQLbubyr+eXRnLi4auZc2PA/Zz0aFNgaU=";
  };

  postPatch = ''
    pushd vcs-versioning
  '';

  env.SETUPTOOLS_SCM_PRETEND_VERSION = finalAttrs.version;
  doCheck = false; # infinite recursion with pytest

  nativeCheckInputs = [
    git
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    packaging
  ];

  pyproject = true;
  pytestFlags = [ "-vvv" ];

  pythonImportsCheck = [
    "vcs_versioning"
  ];

  passthru.tests.pytest = vcs-versioning.overridePythonAttrs { doCheck = true; };

  meta = {
    description = "The blessed package to manage your versions by scm tags";
    homepage = "https://github.com/pypa/setuptools-scm/tree/main/vcs-versioning";
    changelog = "https://github.com/pypa/setuptools-scm/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    teams = [ lib.teams.python ];
  };
})
