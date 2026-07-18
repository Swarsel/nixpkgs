{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  click,
  cloudpickle,
  dask,
  jinja2,
  locket,
  msgpack,
  packaging,
  psutil,
  pyyaml,
  # build-system
  setuptools,
  setuptools-scm,
  sortedcontainers,
  tblib,
  toolz,
  tornado,
  zict,
}:

buildPythonPackage (finalAttrs: {
  pname = "distributed";
  version = "2026.7.0";

  src = fetchFromGitHub {
    owner = "dask";
    repo = "distributed";
    tag = finalAttrs.version;
    hash = "sha256-JwN+Ey+Ii8mELa6oVS+SDiOPYyMcKdaiSjjMqDze+kc=";
  };

  # When tested random tests would fail and not repeatably
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    click
    cloudpickle
    dask
    jinja2
    locket
    msgpack
    packaging
    psutil
    pyyaml
    sortedcontainers
    tblib
    toolz
    tornado
    zict
  ];

  pyproject = true;
  pythonImportsCheck = [ "distributed" ];
  pythonRelaxDeps = [ "dask" ];

  meta = {
    description = "Distributed computation in Python";
    homepage = "https://distributed.readthedocs.io/";
    changelog = "https://github.com/dask/distributed/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ teh ];
  };
})
