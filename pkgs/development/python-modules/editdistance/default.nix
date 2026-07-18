{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  pdm-backend,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "editdistance";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "roy-ht";
    repo = "editdistance";
    tag = "v${version}";
    hash = "sha256-Ncdg8S/UHYqJ1uFnHk9qhHMM3Lrop00woSu3PLKvuBI=";
  };

  nativeBuildInputs = [
    cython
    pdm-backend
    setuptools
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "editdistance" ];

  meta = {
    description = "Python implementation of the edit distance (Levenshtein distance)";
    homepage = "https://github.com/roy-ht/editdistance";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
