{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  pkgconfig,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "uharfbuzz";
  version = "0.53.2";

  src = fetchFromGitHub {
    owner = "harfbuzz";
    repo = "uharfbuzz";
    tag = "v${version}";
    hash = "sha256-EY5jAzcAHY4lmGsitVFtFMijEfAaSCifCjkdJhU2N1g=";
    fetchSubmodules = true;
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    cython
    pkgconfig
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "uharfbuzz" ];

  meta = {
    description = "Streamlined Cython bindings for the harfbuzz shaping engine";
    homepage = "https://github.com/harfbuzz/uharfbuzz";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
