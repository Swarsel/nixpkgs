{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  requests,
  segno,
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "fritzconnection";
  version = "1.15.1";

  src = fetchFromGitHub {
    owner = "kbr";
    repo = "fritzconnection";
    tag = finalAttrs.version;
    hash = "sha256-J07zAXZxQc3TCfsjYcBhQdxsYwHabE9vdj3eMkWua54=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];
  dependencies = [ requests ];

  disabledTestPaths = [
    # Functional tests require network access
    "fritzconnection/tests/test_functional.py"
  ];

  optional-dependencies = {
    qr = [ segno ];
  };

  pyproject = true;
  pythonImportsCheck = [ "fritzconnection" ];

  meta = {
    description = "Python module to communicate with the AVM Fritz!Box";
    homepage = "https://github.com/kbr/fritzconnection";
    changelog = "https://fritzconnection.readthedocs.io/en/${finalAttrs.src.tag}/sources/version_history.html";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      dotlambda
      valodim
    ];
  };
})
