{
  lib,
  buildPythonPackage,
  dask,
  distributed,
  fetchPypi,
  mpi4py,
  setuptools,
}:

buildPythonPackage rec {
  pname = "dask-mpi";
  version = "2025.10.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-YxQOdPrILlB5jlfn/b3SVKUTg87lyjeqazRbGHF1g8A=";
  };

  # Hardcoded mpirun path in tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    dask
    distributed
    mpi4py
  ];

  pyproject = true;
  pythonImportsCheck = [ "dask_mpi" ];

  meta = {
    description = "Deploy Dask using mpi4py";
    homepage = "https://github.com/dask/dask-mpi";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "dask-mpi";
  };
}
