{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  pythonAtLeast,
  setuptools,
  untokenize,
}:

buildPythonPackage rec {
  pname = "unify";
  version = "0.5";

  src = fetchFromGitHub {
    owner = "myint";
    repo = "unify";
    tag = "v${version}";
    hash = "sha256-cWV/Q+LbeIxnQNqyatRWQUF8X+HHlQdc10y9qJ7v3dA=";
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ untokenize ];
  nativeCheckInputs = [ pytestCheckHook ];
  # lib2to3 usage and unmaintained since 2019
  disabled = pythonAtLeast "3.13";

  disabledTests = [
    # https://github.com/myint/unify/issues/21
    "test_format_code"
    "test_format_code_with_backslash_in_comment"
  ];

  pyproject = true;
  pythonImportsCheck = [ "unify" ];

  meta = {
    description = "Modifies strings to all use the same quote where possible";
    homepage = "https://github.com/myint/unify";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ FlorianFranzen ];
    mainProgram = "unify";
  };
}
