{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  python,
}:

buildPythonPackage rec {
  pname = "pylev";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "toastdriven";
    repo = "pylev";
    rev = "v${version}";
    sha256 = "0fgxjdnvnvavnxmxxd0fl5jyr2f31g3a26bwyxcpy56mgpd095c1";
  };

  checkPhase = ''
    ${python.interpreter} -m unittest tests
  '';

  format = "setuptools";
  pythonImportsCheck = [ "pylev" ];

  meta = {
    description = "Python Levenshtein implementation";
    homepage = "https://github.com/toastdriven/pylev";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ jakewaksbaum ];
  };
}
