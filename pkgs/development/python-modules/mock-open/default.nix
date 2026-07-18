{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
}:

buildPythonPackage rec {
  pname = "mock-open";
  version = "1.4.0";

  # no tests in PyPI tarball
  src = fetchFromGitHub {
    owner = "nivbend";
    repo = "mock-open";
    rev = "v${version}";
    sha256 = "0qlz4y8jqxsnmqg03yp9f87rmnjrvmxm5qvm6n1218gm9k5dixbm";
  };

  format = "setuptools";

  meta = {
    description = "Better mock for file I/O";
    homepage = "https://github.com/nivbend/mock-open";
    license = lib.licenses.mit;
  };
}
