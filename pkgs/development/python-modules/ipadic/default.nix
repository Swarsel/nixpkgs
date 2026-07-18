{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  mecab,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "ipadic";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "polm";
    repo = "ipadic-py";
    tag = "v${version}";
    hash = "sha256-ybC8G1AOIZWkS3uQSErXctIJKq9Y7xBjRbBrO8/yAj4=";
  };

  nativeBuildInputs = [
    cython
    mecab
    setuptools-scm
  ];

  # no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "ipadic" ];

  meta = {
    description = "Contemporary Written Japanese dictionary";
    homepage = "https://github.com/polm/ipadic-py";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
