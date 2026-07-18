{
  lib,
  fetchFromGitHub,
  python3Packages,
  writableTmpDirAsHomeHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "fawltydeps";
  version = "0.20.0";

  src = fetchFromGitHub {
    owner = "tweag";
    repo = "FawltyDeps";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RGwCi4SD0khuOZXcR9Leh9WtRautnlJIfuLBnosyUgk=";
  };

  nativeCheckInputs = [
    writableTmpDirAsHomeHook
  ]
  ++ (with python3Packages; [
    pytestCheckHook
    hypothesis
  ]);

  build-system = with python3Packages; [ poetry-core ];

  dependencies = with python3Packages; [
    pyyaml
    importlib-metadata
    isort
    pip-requirements-parser
    pydantic
  ];

  disabledTestPaths = [
    # Disable tests that require network
    "tests/test_install_deps.py"
    "tests/test_resolver.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "fawltydeps" ];

  meta = {
    description = "Find undeclared and/or unused 3rd-party dependencies in your Python project";
    homepage = "https://tweag.github.io/FawltyDeps";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      aleksana
      jherland
    ];

    mainProgram = "fawltydeps";
  };
})
