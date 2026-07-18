{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  einops,
  # dependencies
  einx,
  # build-system
  hatchling,
  loguru,
  packaging,
  # tests
  pytestCheckHook,
  pythonAtLeast,
  torch,
}:

buildPythonPackage (finalAttrs: {
  pname = "x-transformers";
  version = "2.16.1";

  src = fetchFromGitHub {
    owner = "lucidrains";
    repo = "x-transformers";
    tag = finalAttrs.version;
    hash = "sha256-QnNNzPK1lLRpG/Z5tdZKME7tkfvn1lgo7zGUaK/Q548=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];

  dependencies = [
    einx
    einops
    loguru
    packaging
    torch
  ];

  # RuntimeError: torch.compile is not supported on Python 3.14+
  disabledTests = lib.optionals (pythonAtLeast "3.14") [ "test_up" ];
  pyproject = true;
  pythonImportsCheck = [ "x_transformers" ];

  meta = {
    description = "Concise but fully-featured transformer";

    longDescription = ''
      A simple but complete full-attention transformer with a set of promising experimental features from various papers.
    '';

    homepage = "https://github.com/lucidrains/x-transformers";
    changelog = "https://github.com/lucidrains/x-transformers/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ByteSudoer ];
  };
})
