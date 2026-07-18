{
  lib,
  fetchFromGitHub,
  attrs,
  buildPythonPackage,
  mock,
  pythonAtLeast,
  repeated-test,
  setuptools-scm,
  sphinx,
  unittestCheckHook,
}:
buildPythonPackage (finalAttrs: {
  pname = "sigtools";
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "epsy";
    repo = "sigtools";
    tag = "v${finalAttrs.version}";
    hash = "sha256-q5Bzc6fgDJCqt0SA/C/mg2fbUFyXLcsRU+tSl8FdZdI=";
  };

  nativeCheckInputs = [
    mock
    repeated-test
    sphinx
    unittestCheckHook
  ];

  build-system = [ setuptools-scm ];
  dependencies = [ attrs ];
  pyproject = true;
  pythonImportsCheck = [ "sigtools" ];

  unittestFlags = lib.optionals (pythonAtLeast "3.14") [
    "-s sigtools/tests"
    # python314 only: NameError: name 'o' is not defined
    "-k [!RoundTripTests.test_locals]"
  ];

  meta = {
    description = "Utilities for working with inspect.Signature objects";
    homepage = "https://sigtools.readthedocs.io/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
