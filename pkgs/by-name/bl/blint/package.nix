{
  lib,
  fetchFromGitHub,
  nixosTests,
  python3Packages,
  writableTmpDirAsHomeHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "blint";
  version = "3.0.5";

  src = fetchFromGitHub {
    owner = "owasp-dep-scan";
    repo = "blint";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RloxQlnhl4zCto6QO09UZs+29QRCpL0/PJCzYrVi8ng=";
  };

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    pytest-cov-stub
    writableTmpDirAsHomeHook
  ];

  build-system = [
    python3Packages.poetry-core
  ];

  dependencies = with python3Packages; [
    pyyaml
    appdirs
    apsw
    ar
    custom-json-diff
    defusedxml
    email-validator
    lief
    oras
    orjson
    packageurl-python
    pydantic
    rich
    symbolic
  ];

  # only runs on windows and fails, obviously
  disabledTests = [
    "test_demangle"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "blint"
  ];

  pythonRelaxDeps = [
    "apsw"
    "symbolic"
  ];

  passthru.tests = { inherit (nixosTests) blint; };

  meta = {
    description = "Binary Linter to check the security properties, and capabilities in executables";
    homepage = "https://github.com/owasp-dep-scan/blint";
    changelog = "https://github.com/owasp-dep-scan/blint/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
    platforms = lib.platforms.unix;
    mainProgram = "blint";
    teams = with lib.teams; [ ngi ];
  };
})
