{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cytoolz,
  # dependencies
  eth-hash,
  eth-typing,
  # tests
  hypothesis,
  isPyPy,
  mypy,
  pydantic,
  pytestCheckHook,
  # build-system
  setuptools,
  toolz,
}:

buildPythonPackage (finalAttrs: {
  pname = "eth-utils";
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "ethereum";
    repo = "eth-utils";
    tag = "v${finalAttrs.version}";
    hash = "sha256-U1RSKaLw/gDg4lMjkTwR/Wfb5wqQctML9CDZBILMBys=";
  };

  postPatch = ''
    # type inference test output expectation changed slightly (don't ask me when it started...)
    sed -i 's/builtins\.//g' tests/core/functional-utils/test_type_inference.py
  '';

  nativeCheckInputs = [
    hypothesis
    mypy
    pytestCheckHook
    pydantic
  ]
  ++ eth-hash.optional-dependencies.pycryptodome;

  build-system = [ setuptools ];

  dependencies = [
    eth-hash
    eth-typing
  ]
  ++ lib.optional (!isPyPy) cytoolz
  ++ lib.optional isPyPy toolz;

  disabledTestPaths = [
    # Typing tests fail like:
    #   Revealed type is "builtins.tuple[builtins.int, ...]"
    "tests/core/functional-utils/test_type_inference.py"
  ];

  disabledTests = [
    # Exception: Expected one wheel. Instead found: [] in project /build/source
    "test_install_local_wheel"
  ];

  pyproject = true;
  pythonImportsCheck = [ "eth_utils" ];

  meta = {
    description = "Common utility functions for codebases which interact with ethereum";
    homepage = "https://github.com/ethereum/eth-utils";
    changelog = "https://github.com/ethereum/eth-utils/blob/${finalAttrs.src.tag}/docs/release_notes.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ siraben ];
  };
})
