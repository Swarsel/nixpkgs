{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "zxcvbn";
  version = "4.5.0";

  # no tests included in PyPI tarball
  src = fetchFromGitHub {
    owner = "dwolfhub";
    repo = "zxcvbn-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0SVJkJMEMnZVMpamDVP02kMwWRSj5zGlrMYG9kn0aXQ=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "zxcvbn" ];

  meta = {
    description = "Python implementation of Dropbox's realistic password strength estimator";
    homepage = "https://github.com/dwolfhub/zxcvbn-python";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "zxcvbn";
  };
})
