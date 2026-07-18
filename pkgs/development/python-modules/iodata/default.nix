{
  lib,
  fetchFromGitHub,
  attrs,
  buildPythonPackage,
  numpy,
  pytest-xdist,
  pytestCheckHook,
  scipy,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "iodata";
  version = "1.0.0a4";

  src = fetchFromGitHub {
    owner = "theochem";
    repo = "iodata";
    tag = "v${version}";
    hash = "sha256-ld6V+/8lg4Du6+mHU5XuXXyMpWwyepXurerScg/bf2Q=";
  };

  nativeCheckInputs = [
    pytest-xdist
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    numpy
    scipy
    attrs
  ];

  pyproject = true;
  pythonImportsCheck = [ "iodata" ];

  meta = {
    description = "Python library for reading, writing, and converting computational chemistry file formats and generating input files";
    homepage = "https://github.com/theochem/iodata";
    license = lib.licenses.lgpl3Only;
    maintainers = [ lib.maintainers.sheepforce ];
    mainProgram = "iodata-convert";
  };
}
