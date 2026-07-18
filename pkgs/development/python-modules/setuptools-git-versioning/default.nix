{
  lib,
  fetchFromGitHub,
  build,
  buildPythonPackage,
  coverage,
  git,
  packaging,
  pytest-rerunfailures,
  pytestCheckHook,
  setuptools,
  tomli-w,
}:

buildPythonPackage rec {
  pname = "setuptools-git-versioning";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "dolfinus";
    repo = "setuptools-git-versioning";
    tag = "v${version}";
    hash = "sha256-rAJ9OvSKhQ3sMN5DlUg2tfR42Ae7jjz9en3gfRnXb3I=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'dynamic = ["version"]' 'version = "${version}"'
  '';

  nativeCheckInputs = [
    build
    coverage
    git
    pytestCheckHook
    pytest-rerunfailures
    tomli-w
  ];

  preCheck = ''
    # so that its built binary is accessible by tests
    export PATH="$out/bin:$PATH"
  '';

  build-system = [
    packaging
    setuptools
  ];

  dependencies = [
    packaging
    setuptools
  ];

  disabledTests = [
    # runs an isolated build that uses internet to download dependencies
    "test_config_not_used"
  ];

  # limit tests because the full suite takes several minutes to run
  enabledTestMarks = [
    "important"
  ];

  pyproject = true;
  pythonImportsCheck = [ "setuptools_git_versioning" ];

  meta = {
    description = "Use git repo data (latest tag, current commit hash, etc) for building a version number according PEP-440";
    homepage = "https://github.com/dolfinus/setuptools-git-versioning";
    changelog = "https://github.com/dolfinus/setuptools-git-versioning/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    mainProgram = "setuptools-git-versioning";
  };
}
