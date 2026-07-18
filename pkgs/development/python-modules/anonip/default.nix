{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "anonip";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "DigitaleGesellschaft";
    repo = "Anonip";
    rev = "v${version}";
    sha256 = "0cssdcridadjzichz1vv1ng7jwphqkn8ihh83hpz9mcjmxyb94qc";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  enabledTestPaths = [ "tests.py" ];
  format = "setuptools";
  pythonImportsCheck = [ "anonip" ];

  meta = {
    description = "Tool to anonymize IP addresses in log files";
    homepage = "https://github.com/DigitaleGesellschaft/Anonip";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ mmahut ];
    mainProgram = "anonip";
  };
}
