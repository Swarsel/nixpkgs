{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "cache";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "jneen";
    repo = "python-cache";
    tag = "v${version}";
    hash = "sha256-vfVNo2B9fnjyjgR7cGrcsi9srWcTs3s8fhmvNF8okN0=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  disabledTests = [
    # Tests are out-dated
    "test_arguments"
    "test_hash_arguments"
  ];

  pyproject = true;
  pythonImportsCheck = [ "cache" ];

  meta = {
    description = "Module for caching";
    homepage = "https://github.com/jneen/python-cache";
    changelog = "https://github.com/jneen/python-cache/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
