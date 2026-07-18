{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "immutabledict";
  version = "4.3.1";

  src = fetchFromGitHub {
    owner = "corenting";
    repo = "immutabledict";
    tag = "v${version}";
    hash = "sha256-BZ3qiYZtw5YcWTy2rtlDZE3J1Hia9/Yniy+I7xhq7AE=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];

  disabledTests = [
    # fails if builder load is highly variable
    "test_performance"
  ];

  pyproject = true;
  pythonImportsCheck = [ "immutabledict" ];

  meta = {
    description = "Fork of frozendict, an immutable wrapper around dictionaries";
    homepage = "https://github.com/corenting/immutabledict";
    changelog = "https://github.com/corenting/immutabledict/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
