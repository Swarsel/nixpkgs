{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  lxml,
  python,
  setuptools,
}:

buildPythonPackage rec {
  pname = "defusedxml";
  version = "0.8.0rc2";

  src = fetchFromGitHub {
    owner = "tiran";
    repo = "defusedxml";
    tag = "v${version}";
    hash = "sha256-X88A5V9uXP3wJQ+olK6pZJT66LP2uCXLK8goa5bPARA=";
  };

  nativeCheckInputs = [ lxml ];

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} tests.py
    runHook postCheck
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "defusedxml" ];

  meta = {
    description = "Python module to defuse XML issues";
    homepage = "https://github.com/tiran/defusedxml";
    changelog = "https://github.com/tiran/defusedxml/blob/v${version}/CHANGES.txt";
    license = lib.licenses.psfl;
    maintainers = with lib.maintainers; [ fab ];
  };
}
