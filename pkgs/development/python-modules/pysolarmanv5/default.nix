{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  umodbus,
}:

buildPythonPackage rec {
  pname = "pysolarmanv5";
  version = "3.0.6";

  src = fetchFromGitHub {
    owner = "jmccrohan";
    repo = "pysolarmanv5";
    tag = "v${version}";
    hash = "sha256-ENEXuMQGQ1Jwgpfp2v0T2dveTJoIaVu+DfefQZy8ntE=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  dependencies = [
    umodbus
  ];

  pyproject = true;
  pythonImportsCheck = [ "pysolarmanv5" ];

  meta = {
    description = "Python module to interact with Solarman Data Logging Sticks";
    homepage = "https://github.com/jmccrohan/pysolarmanv5";
    changelog = "https://github.com/jmccrohan/pysolarmanv5/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Scrumplex ];
  };
}
