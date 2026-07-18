{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cachecontrol,
  legacy-cgi,
  lxml-html-clean,
  pytestCheckHook,
  requests,
  setuptools,
  six,
}:

buildPythonPackage (finalAttrs: {
  pname = "pywebcopy";
  version = "7.1";

  src = fetchFromGitHub {
    owner = "rajatomar788";
    repo = "pywebcopy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ee8uGg4PU1uch8cyiU7QfvdYFUVDz7obq9oC8fKkf1s=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    cachecontrol
    legacy-cgi
    lxml-html-clean
    requests
    six
  ];

  disabledTestPaths = [
    # Segfault
    "pywebcopy/tests/test_iterparser.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pywebcopy" ];

  meta = {
    description = "Python package for cloning complete webpages and websites to local storage";
    homepage = "https://github.com/rajatomar788/pywebcopy/";
    changelog = "https://github.com/rajatomar788/pywebcopy/releases/tag/v${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
