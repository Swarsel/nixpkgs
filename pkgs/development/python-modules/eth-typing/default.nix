{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-xdist,
  # nativeCheckInputs
  pytestCheckHook,
  setuptools,
  # dependencies
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "eth-typing";
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "ethereum";
    repo = "eth-typing";
    tag = "v${version}";
    hash = "sha256-bdZrrglsJGNsqD6ShsqPO6ljViZr9Ms9A8Km45pnEYA=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-xdist
  ];

  build-system = [ setuptools ];
  dependencies = [ typing-extensions ];

  disabledTests = [
    # side-effect: runs pip online check and is blocked by sandbox
    "test_install_local_wheel"
  ];

  pyproject = true;
  pythonImportsCheck = [ "eth_typing" ];

  meta = {
    description = "Common type annotations for Ethereum Python packages";
    homepage = "https://github.com/ethereum/eth-typing";
    changelog = "https://github.com/ethereum/eth-typing/blob/v${version}/docs/release_notes.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ siraben ];
  };
}
