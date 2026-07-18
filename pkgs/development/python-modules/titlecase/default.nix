{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  regex,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "titlecase";
  version = "2.4.1";

  src = fetchFromGitHub {
    owner = "ppannuto";
    repo = "python-titlecase";
    tag = "v${finalAttrs.version}";
    hash = "sha256-s+C0UOKLEpMksfePIB6VzTv0dFLeamurdxjf5u1ek3g=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools-scm ];
  dependencies = [ regex ];
  enabledTestPaths = [ "titlecase/tests.py" ];
  pyproject = true;
  pythonImportsCheck = [ "titlecase" ];

  meta = {
    description = "Python library to capitalize strings as specified by the New York Times";
    homepage = "https://github.com/ppannuto/python-titlecase";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "titlecase";
  };
})
