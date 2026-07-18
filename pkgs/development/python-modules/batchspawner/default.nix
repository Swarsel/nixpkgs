{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  jinja2,
  jupyterhub,
  # tests
  pytest-asyncio_0,
  pytest-cov-stub,
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "batchspawner";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "jupyterhub";
    repo = "batchspawner";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Z7kB8b7s11wokTachLI/N+bdUV+FfCRTemL1KYQpzio=";
  };

  # When using pytest-asyncio>=0.24, jupyterhub no longer re-defines the event_loop function in its
  # conftest.py, so it cannot be imported from there.
  postPatch = ''
    substituteInPlace batchspawner/tests/conftest.py \
      --replace-fail \
        "from jupyterhub.tests.conftest import db, event_loop  # noqa" \
        "from jupyterhub.tests.conftest import db"
  '';

  nativeCheckInputs = [
    pytest-asyncio_0
    pytest-cov-stub
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    jinja2
    jupyterhub
  ];

  pyproject = true;
  pythonImportsCheck = [ "batchspawner" ];

  meta = {
    description = "Spawner for Jupyterhub to spawn notebooks using batch resource managers";
    homepage = "https://github.com/jupyterhub/batchspawner";
    changelog = "https://github.com/jupyterhub/batchspawner/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "batchspawner-singleuser";
  };
})
