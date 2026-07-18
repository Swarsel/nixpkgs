{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  cloudpickle,
  # build-system
  flit-core,
  pytest-asyncio,
  # tests
  pytestCheckHook,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "submitit";
  version = "1.5.4";

  src = fetchFromGitHub {
    owner = "facebookincubator";
    repo = "submitit";
    tag = finalAttrs.version;
    hash = "sha256-Q/2mC7viLYl8fx7dtQueZqT191EbERZPfN0WkTS/U1w=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  __structuredAttrs = true;
  build-system = [ flit-core ];

  dependencies = [
    cloudpickle
    typing-extensions
  ];

  disabledTests = [
    # These tests are broken
    "test_setup"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Fails in the sandbox:
    #   AssertionError: Should have resumed from a checkpoint
    "test_requeuing"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "submitit"
  ];

  meta = {
    description = "Python 3.8+ toolbox for submitting jobs to Slurm";
    homepage = "https://github.com/facebookincubator/submitit";
    changelog = "https://github.com/facebookincubator/submitit/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.nickcao ];
  };
})
