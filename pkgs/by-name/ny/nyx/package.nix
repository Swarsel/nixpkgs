{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "nyx";
  version = "2.1.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    sha256 = "02rrlllz2ci6i6cs3iddyfns7ang9a54jrlygd2jw1f9s6418ll8";
  };

  # ./run_tests.py returns `TypeError: testFailure() takes exactly 1 argument`
  doCheck = false;
  build-system = with python3Packages; [ setuptools ];
  dependencies = with python3Packages; [ stem ];
  pyproject = true;
  pythonImportsCheck = [ "nyx" ];

  meta = {
    description = "Command-line monitor for Tor";
    homepage = "https://nyx.torproject.org/";
    license = lib.licenses.gpl3;
    maintainers = [ ];
    mainProgram = "nyx";
  };
})
