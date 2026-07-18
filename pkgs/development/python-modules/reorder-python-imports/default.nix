{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  classify-imports,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "reorder-python-imports";
  version = "3.16.0";

  src = fetchFromGitHub {
    owner = "asottile";
    repo = "reorder_python_imports";
    tag = "v${version}";
    hash = "sha256-fncrrmksYS+8pz9qVucf4ktxxVvnrKEzIeM5kPrh0PQ=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ classify-imports ];
  # prints an explanation about PYTHONPATH first
  # and therefore fails the assertion
  disabledTests = [ "test_success_messages_are_printed_on_stderr" ];
  pyproject = true;
  pythonImportsCheck = [ "reorder_python_imports" ];

  meta = {
    description = "Tool for automatically reordering python imports";
    homepage = "https://github.com/asottile/reorder_python_imports";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ gador ];
    mainProgram = "reorder-python-imports";
  };
}
