{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "mnamer";
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "jkwill87";
    repo = "mnamer";
    tag = finalAttrs.version;
    sha256 = "sha256-lu1DWbR7LkaRddeAAHBWM61cnEZG4KVZdQWWRsbghb8=";
  };

  patches = [
    # https://github.com/jkwill87/mnamer/pull/291
    ./cached_session_error.patch
    # https://github.com/jkwill87/mnamer/pull/333
    ./fix-requests-cache-version-check.patch
  ];

  nativeCheckInputs = [ python3Packages.pytestCheckHook ];

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3Packages; [
    appdirs
    babelfish
    guessit
    requests
    requests-cache
    teletype
  ];

  # disable test that fail (networking, etc)
  disabledTests = [
    "network"
    "e2e"
    "test_utils.py"
  ];

  pyproject = true;
  pythonRelaxDeps = true;

  meta = {
    description = "Intelligent and highly configurable media organization utility";
    homepage = "https://github.com/jkwill87/mnamer";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "mnamer";
  };
})
