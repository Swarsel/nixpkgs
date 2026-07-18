{
  lib,
  fetchFromGitHub,
  brotli,
  buildPythonPackage,
  fetchPypi,
  lz4,
  setuptools,
}:

let
  kaitai_compress = fetchFromGitHub {
    hash = "sha256-l3rGbblUgxO6Y7grlsMEiT3nRIgUZV1VqTyjIgIDtyA=";
    owner = "kaitai-io";
    repo = "kaitai_compress";
    rev = "12f4cffb45d95b17033ee4f6679987656c6719cc";
  };
in
buildPythonPackage rec {
  pname = "kaitaistruct";
  version = "0.11";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-BT7nZCiOeLjlOs90jpczJorL1Xm42CpCexgFRTYl10s=";
  };

  patches = [ ./01-add-kaitai-compress.patch ];

  propagatedBuildInputs = [
    brotli
    lz4
  ];

  preBuild = ''
    ln -s ${kaitai_compress}/python/kaitai kaitai
  '';

  doCheck = false; # no tests in upstream
  build-system = [ setuptools ];
  pyproject = true;

  pythonImportsCheck = [
    "kaitaistruct"
    "kaitai.compress"
  ];

  meta = {
    description = "Kaitai Struct: runtime library for Python";
    homepage = "https://github.com/kaitai-io/kaitai_struct_python_runtime";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
