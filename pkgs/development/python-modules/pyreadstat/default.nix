{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  narwhals,
  pandas,
  python,
  readstat,
  setuptools,
  zlib,
}:

buildPythonPackage rec {
  pname = "pyreadstat";
  version = "1.3.5";

  src = fetchFromGitHub {
    owner = "Roche";
    repo = "pyreadstat";
    tag = "v${version}";
    hash = "sha256-9SSY8wX0CMEjoSOHZHH9z5e5/PU4EsXiRxu8f2EXzZk=";
  };

  buildInputs = [ zlib ];

  preCheck = ''
    export HOME=$(mktemp -d);
  '';

  checkPhase = ''
    runHook preCheck

    ${python.interpreter} tests/test_basic.py

    runHook postCheck
  '';

  build-system = [
    cython
    setuptools
  ];

  dependencies = [
    narwhals
    readstat
    pandas
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyreadstat" ];

  meta = {
    description = "Module to read SAS, SPSS and Stata files into pandas data frames";
    homepage = "https://github.com/Roche/pyreadstat";
    changelog = "https://github.com/Roche/pyreadstat/blob/${src.tag}/change_log.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ swflint ];
  };
}
