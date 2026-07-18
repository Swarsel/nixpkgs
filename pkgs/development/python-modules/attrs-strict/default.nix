{
  lib,
  fetchFromGitHub,
  # dependencies
  attrs,
  buildPythonPackage,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "attrs-strict";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "bloomberg";
    repo = "attrs-strict";
    tag = finalAttrs.version;
    hash = "sha256-dDOD4Y57E+i8D0S4q+C6t7zjBTsS8q2UFiS22Dsp0Z8=";
  };

  patches = [
    # Upstream PR: https://github.com/bloomberg/attrs-strict/pull/117
    ./fix-tests.patch
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    attrs
  ];

  pyproject = true;
  pythonImportsCheck = [ "attrs_strict" ];

  meta = {
    description = "Python package which contains runtime validation for attrs data classes based on the types existing in the typing module";
    homepage = "https://github.com/bloomberg/attrs-strict";
    changelog = "https://github.com/bloomberg/attrs-strict/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
