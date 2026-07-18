{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flake8,
  python,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pep8-naming";
  version = "0.15.1";

  src = fetchFromGitHub {
    owner = "PyCQA";
    repo = "pep8-naming";
    tag = version;
    hash = "sha256-swSaMOrgd6R4i92LodJVsquls9wp5ZFyzK0LNqwODoc=";
  };

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} run_tests.py
    runHook postCheck
  '';

  build-system = [ setuptools ];
  dependencies = [ flake8 ];
  pyproject = true;
  pythonImportsCheck = [ "pep8ext_naming" ];

  meta = {
    description = "Check PEP-8 naming conventions, plugin for flake8";
    homepage = "https://github.com/PyCQA/pep8-naming";
    changelog = "https://github.com/PyCQA/pep8-naming/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ eadwu ];
  };
}
