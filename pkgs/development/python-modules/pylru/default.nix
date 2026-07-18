{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pylru";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "jlhutch";
    repo = "pylru";
    rev = "v${version}";
    hash = "sha256-3qycUYmnLGiuNsrBOCL/QiRkrPVikaRqVBmQFURDGKs=";
  };

  checkPhase = ''
    runHook preCheck

    python test.py

    runHook postCheck
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pylru" ];

  meta = {
    description = "Least recently used (LRU) cache implementation";
    homepage = "https://github.com/jlhutch/pylru";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
