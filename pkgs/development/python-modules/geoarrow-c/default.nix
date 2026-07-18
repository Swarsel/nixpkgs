{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  numpy,
  pyarrow,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:
buildPythonPackage rec {
  pname = "geoarrow-c";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "geoarrow";
    repo = "geoarrow-c";
    tag = "geoarrow-c-python-${version}";
    hash = "sha256-cSvFCIMHuwDh83DT3R3V86S+RjPzhqcnTaFXqKL43Ns=";
  };

  # upstream needs a bootstrap.py file to copy some source around to build the project.
  # This file is executed by setup.py, so at build time, when sources are readonly!
  # So we execute this file at patch time instead, and remove it to prevent setup.py to execute it again.
  postPatch = ''
    python ./bootstrap.py
    rm -v ./bootstrap.py
  '';

  preConfigure = ''
    export CFLAGS="-I../../src/src/geoarrow"
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pyarrow
    numpy
  ];

  build-system = [
    cython
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "geoarrow.c" ];
  sourceRoot = "${src.name}/python/geoarrow-c";

  meta = {
    description = "Experimental C and C++ implementation of the GeoArrow specification";
    homepage = "https://github.com/geoarrow/geoarrow-c";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      cpcloud
    ];

    teams = [ lib.teams.geospatial ];
  };
}
