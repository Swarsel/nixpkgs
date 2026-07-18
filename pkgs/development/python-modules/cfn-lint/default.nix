{
  lib,
  fetchFromGitHub,
  aws-sam-translator,
  buildPythonPackage,
  defusedxml,
  jschema-to-python,
  jsonpatch,
  junit-xml,
  mock,
  networkx,
  pydot,
  pytestCheckHook,
  pyyaml,
  regex,
  sarif-om,
  setuptools,
  sympy,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "cfn-lint";
  version = "1.43.3";

  src = fetchFromGitHub {
    owner = "aws-cloudformation";
    repo = "cfn-lint";
    tag = "v${version}";
    hash = "sha256-tolQ7O6J/pfmtw29t8SGBDEDGiTOsJdc/mI3ulUseKo=";
  };

  nativeCheckInputs = [
    defusedxml
    mock
    pytestCheckHook
  ]
  ++ optional-dependencies.full;

  preCheck = ''
    export PATH=$out/bin:$PATH
  '';

  build-system = [ setuptools ];

  dependencies = [
    aws-sam-translator
    jsonpatch
    networkx
    pyyaml
    regex
    sympy
    typing-extensions
  ];

  disabledTestPaths = [
    # unexpected exit code afer nodejs_24 24.16.0 update
    "test/integration/test_quickstart_templates.py::TestQuickStartTemplates::test_templates"
    "test/integration/test_quickstart_templates_non_strict.py::TestQuickStartTemplates::test_module_integration"
    "test/integration/test_quickstart_templates_non_strict.py::TestQuickStartTemplates::test_templates"
    "test/integration/test_good_templates.py::TestQuickStartTemplates::test_module_integration"
    "test/integration/test_good_templates.py::TestQuickStartTemplates::test_templates"
  ];

  disabledTests = [
    # Requires git directory
    "test_update_docs"
  ];

  optional-dependencies = {
    full = lib.concatAttrValues (lib.removeAttrs optional-dependencies [ "full" ]);
    graph = [ pydot ];
    junit = [ junit-xml ];

    sarif = [
      jschema-to-python
      sarif-om
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "cfnlint" ];

  meta = {
    description = "Checks cloudformation for practices and behaviour that could potentially be improved";
    homepage = "https://github.com/aws-cloudformation/cfn-lint";
    changelog = "https://github.com/aws-cloudformation/cfn-lint/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "cfn-lint";
  };
}
