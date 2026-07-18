{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nh3,
  pillow,
  pytest-cov-stub,
  pytestCheckHook,
  regex,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "textile";
  version = "4.0.4";

  src = fetchFromGitHub {
    owner = "textile";
    repo = "python-textile";
    tag = finalAttrs.version;
    hash = "sha256-fHji+TOIFVljkvlOaRp/8EnZ6KYgMu/DLpg6PmOSEbk=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    nh3
    regex
  ];

  optional-dependencies = {
    imagesize = [ pillow ];
  };

  pyproject = true;
  pythonImportsCheck = [ "textile" ];

  meta = {
    description = "Module for generating web text";
    homepage = "https://github.com/textile/python-textile";
    changelog = "https://github.com/textile/python-textile/blob/${finalAttrs.src.tag}/CHANGELOG.textile";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "pytextile";
  };
})
