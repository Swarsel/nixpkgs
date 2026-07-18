{
  lib,
  buildPythonPackage,
  cython,
  fetchPypi,
  nasm,
  setuptools,
}:

buildPythonPackage rec {
  pname = "rapidgzip";
  version = "0.16.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ixJPKbwS3kJJq4HoPlrTXmd0KhqP9Ky2G3TA2f2hwU4=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools >= 61.2, < 72" setuptools
  '';

  nativeBuildInputs = [ nasm ];
  # has no tests
  doCheck = false;

  build-system = [
    cython
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "rapidgzip" ];

  meta = {
    description = "Python library for parallel decompression and seeking within compressed gzip files";
    homepage = "https://github.com/mxmlnkn/rapidgzip";
    changelog = "https://github.com/mxmlnkn/rapidgzip/blob/rapidgzip-v${version}/python/rapidgzip/CHANGELOG.md";
    license = lib.licenses.mit; # dual MIT and asl20, https://internals.rust-lang.org/t/rationale-of-apache-dual-licensing/8952
    maintainers = with lib.maintainers; [ mxmlnkn ];
    mainProgram = "rapidgzip";
  };
}
