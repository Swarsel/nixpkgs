{
  lib,
  fetchFromGitHub,
  # dependencies
  binaryornot,
  buildPythonPackage,
  # build-system
  pdm-backend,
  # tests
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "test2ref";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "nbiotcloud";
    repo = "test2ref";
    tag = "v${finalAttrs.version}";
    hash = "sha256-20vE6o8yKphKxlfGo+lBZ1VlKyCVlNawlMYVcj4JAtY=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    pdm-backend
  ];

  dependencies = [
    binaryornot
  ];

  disabledTests = [
    # AssertionError:
    #   Only in /build/pytest-of-nixbld/pytest-0/test_known0/ref: file0.txt
    #   Only in /build/pytest-of-nixbld/pytest-0/test_known0/ref: sub0
    # Reported upstream: https://github.com/nbiotcloud/test2ref/issues/36
    "test_known"
  ];

  pyproject = true;
  pythonImportsCheck = [ "test2ref" ];

  meta = {
    description = "Testing Against Learned Reference Data";
    homepage = "https://github.com/nbiotcloud/test2ref";
    changelog = "https://github.com/nbiotcloud/test2ref/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
