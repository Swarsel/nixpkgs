{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "apipkg";
  version = "3.0.2";

  src = fetchFromGitHub {
    owner = "pytest-dev";
    repo = "apipkg";
    tag = "v${version}";
    hash = "sha256-ANLD7fUMKN3RmAVjVkcpwUH6U9ASalXdwKtPpoC8Urs=";
  };

  # support pytest 9: https://github.com/pytest-dev/apipkg/pull/58
  postPatch = ''
    substituteInPlace conftest.py \
      --replace-fail 'def pytest_report_header(startdir):' 'def pytest_report_header():'
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  enabledTestPaths = [ "test_apipkg.py" ];
  pyproject = true;
  pythonImportsCheck = [ "apipkg" ];

  meta = {
    description = "Namespace control and lazy-import mechanism";
    homepage = "https://github.com/pytest-dev/apipkg";
    changelog = "https://github.com/pytest-dev/apipkg/blob/main/CHANGELOG";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
