{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cython,
  # dependencies
  mpi4py,
  numpy,
  pkgconfig,
  precice,
  setuptools,
  setuptools-git-versioning,
}:

buildPythonPackage rec {
  pname = "pyprecice";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "precice";
    repo = "python-bindings";
    tag = "v${version}";
    hash = "sha256-fKpedgdgXTRVHcTdU996xbIi/b2GlCued8xnL41KHVg=";
  };

  buildInputs = [
    precice
  ];

  # no official test instruction
  doCheck = false;

  build-system = [
    cython
    pkgconfig
    setuptools
    setuptools-git-versioning
  ];

  dependencies = [
    numpy
    mpi4py
  ];

  pyproject = true;

  pythonImportsCheck = [
    "precice"
  ];

  meta = {
    description = "Python language bindings for preCICE";
    homepage = "https://github.com/precice/python-bindings";
    changelog = "https://github.com/precice/python-bindings/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ Scriptkiddi ];
  };
}
