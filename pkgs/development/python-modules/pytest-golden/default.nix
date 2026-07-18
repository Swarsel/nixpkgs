{
  lib,
  fetchFromGitHub,
  atomicwrites,
  buildPythonPackage,
  hatchling,
  pytest,
  pytestCheckHook,
  ruamel-yaml,
  testfixtures,
}:

buildPythonPackage rec {
  pname = "pytest-golden";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "oprypin";
    repo = "pytest-golden";
    tag = "v${version}";
    hash = "sha256-mjb8lBAoZxwUCN4AIMK/n70aC41Y4IV/+hrW11S9rcw=";
  };

  buildInputs = [ pytest ];
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    hatchling
  ];

  dependencies = [
    atomicwrites
    ruamel-yaml
    testfixtures
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytest_golden" ];
  pythonRelaxDeps = [ "testfixtures" ];

  meta = {
    description = "Plugin for pytest that offloads expected outputs to data files";
    homepage = "https://github.com/oprypin/pytest-golden";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
