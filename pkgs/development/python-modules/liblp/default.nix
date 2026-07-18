{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
}:

buildPythonPackage rec {
  pname = "liblp";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "sebaubuntu-python";
    repo = "liblp";
    tag = "v${version}";
    hash = "sha256-F30D2mYUYPupbr8OsrcrN6wQ639L5OlzQw/FrxPCsC4=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "liblp" ];

  meta = {
    description = "Android logical partitions library ported from C++ to Python";
    homepage = "https://github.com/sebaubuntu-python/liblp";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ungeskriptet ];
    mainProgram = "lpunpack";
  };
}
