{
  lib,
  fetchFromGitHub,
  astroid,
  buildPythonPackage,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "asttokens";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "gristlabs";
    repo = "asttokens";
    tag = "v${version}";
    hash = "sha256-1qkkNpjX89TmGD0z0KA2y+UbiHuEOaXzZ6hs9nw7EeM=";
  };

  nativeCheckInputs = [
    astroid
    pytestCheckHook
  ];

  build-system = [ setuptools-scm ];

  disabledTestPaths = [
    # incompatible with astroid 2.11.0, pins <= 2.5.3
    "tests/test_astroid.py"
  ];

  disabledTests = [
    # Test is currently failing on Hydra, works locally
    "test_slices"
  ];

  pyproject = true;
  pythonImportsCheck = [ "asttokens" ];

  meta = {
    description = "Annotate Python AST trees with source text and token information";
    homepage = "https://github.com/gristlabs/asttokens";
    changelog = "https://github.com/gristlabs/asttokens/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
