{
  lib,
  bqscales,
  buildPythonPackage,
  fetchPypi,
  ipywidgets,
  jupyter-packaging,
  jupyterlab,
  numpy,
  pandas,
  traitlets,
  traittypes,
}:

buildPythonPackage rec {
  pname = "bqplot";
  version = "0.12.46";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-lBdL4+skHJ+h1pelQxMomgvT/ogK3ZbGZA0xY73T0io=";
  };

  # upstream seems in flux for 0.13 release. they seem to want to migrate from
  # jupyter_packaging to hatch, so let's patch instead of fixing upstream
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace "jupyter_packaging~=" "jupyter_packaging>=" \
      --replace "jupyterlab~=" "jupyterlab>="
  '';

  # no tests in PyPI dist, and not obvious to me how to build the js files from GitHub
  doCheck = false;

  build-system = [
    jupyter-packaging
    jupyterlab
  ];

  dependencies = [
    bqscales
    ipywidgets
    numpy
    pandas
    traitlets
    traittypes
  ];

  pyproject = true;

  pythonImportsCheck = [
    "bqplot"
    "bqplot.pyplot"
  ];

  meta = {
    description = "2D plotting library for Jupyter based on Grammar of Graphics";
    homepage = "https://bqplot.github.io/bqplot";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
