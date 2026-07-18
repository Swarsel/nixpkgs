{
  lib,
  fetchFromGitHub,
  python3,
  versionCheckHook,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "snmpen";
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "fabaff";
    repo = "snmpen";
    tag = finalAttrs.version;
    hash = "sha256-4/QLPq4td2o17lIhktl5aVKz5esWibVoVm8OdVIxWmM=";
  };

  nativeBuildInputs = with python3.pkgs; [
    pytestCheckHook
    pytest-asyncio
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  build-system = with python3.pkgs; [ hatchling ];

  dependencies = with python3.pkgs; [
    humanize
    pysnmp
    rich
  ];

  pyproject = true;
  pythonImportsCheck = [ "snmpen" ];

  meta = {
    description = "SNMP Enumeration tool";
    homepage = "https://github.com/affolter-engineering/snmpen";
    changelog = "https://github.com/affolter-engineering/snmpen/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "snmpen";
  };
})
