{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatchling,
  # tests
  pytestCheckHook,
  trio,
}:

buildPythonPackage (finalAttrs: {
  pname = "tinyio";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "patrick-kidger";
    repo = "tinyio";
    tag = "v${finalAttrs.version}";
    hash = "sha256-a1EbgFcyWz0aihX16ZQbcAwKKneUe+b8qV0cHyMchVI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    trio
  ];

  build-system = [
    hatchling
  ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # AssertionError
    # assert 0 >= 4, where 0 = sum([False, False, False, False, False])
    "test_sleep"
  ];

  pyproject = true;
  pythonImportsCheck = [ "tinyio" ];

  meta = {
    description = "Dead-simple event loop for Python";
    homepage = "https://github.com/patrick-kidger/tinyio";
    changelog = "https://github.com/patrick-kidger/tinyio/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
