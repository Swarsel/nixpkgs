{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pandas,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ancp-bids";
  version = "0.3.1";

  # `tests/data` dir missing from PyPI dist
  src = fetchFromGitHub {
    owner = "ANCPLabOldenburg";
    repo = "ancp-bids";
    tag = version;
    hash = "sha256-brkhXz2b1nR/tjkZQZY5S+P0+GbESvJsANQcVWRCa9k=";
  };

  nativeCheckInputs = [
    numpy
    pandas
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  disabledTests = [ "test_fetch_dataset" ];
  enabledTestPaths = [ "tests/auto" ];
  pyproject = true;
  pythonImportsCheck = [ "ancpbids" ];

  meta = {
    description = "Read/write/validate/query BIDS datasets";
    homepage = "https://ancpbids.readthedocs.io";
    changelog = "https://github.com/ANCPLabOldenburg/ancp-bids/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
