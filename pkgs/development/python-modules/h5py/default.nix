{
  lib,
  buildPythonPackage,
  cython,
  fetchPypi,
  hdf5,
  numpy,
  openssh,
  pkgconfig,
  pytest-mpi,
  pytestCheckHook,
  setuptools,
  mpi4py ? null,
}:

assert hdf5.mpiSupport -> mpi4py != null && hdf5.mpi == mpi4py.mpi;

let
  mpi = hdf5.mpi;
  mpiSupport = hdf5.mpiSupport;
in
buildPythonPackage rec {
  pname = "h5py";
  version = "3.15.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-yG4+1FxEc1ZN5VqoO2/J5erYZXh3PfvZMEc4AELia2k=";
  };

  buildInputs = [ hdf5 ] ++ lib.optional mpiSupport mpi;

  env = {
    # See discussion at https://github.com/h5py/h5py/issues/2560
    H5PY_SETUP_REQUIRES = 0;
    HDF5_DIR = "${hdf5}";
    HDF5_MPI = if mpiSupport then "ON" else "OFF";
  };

  postConfigure = ''
    # Needed to run the tests reliably. See:
    # https://bitbucket.org/mpi4py/mpi4py/issues/87/multiple-test-errors-with-openmpi-30
    ${lib.optionalString mpiSupport "export OMPI_MCA_rmaps_base_oversubscribe=yes"}
  '';

  preBuild = lib.optionalString mpiSupport "export CC=${lib.getDev mpi}/bin/mpicc";

  nativeCheckInputs = [
    pytestCheckHook
    pytest-mpi
    openssh
  ];

  # https://github.com/NixOS/nixpkgs/issues/255262
  preCheck = ''
    cd $out
  '';

  build-system = [
    cython
    numpy
    pkgconfig
    setuptools
  ];

  dependencies = [
    numpy
  ]
  ++ lib.optionals mpiSupport [
    mpi4py
    openssh
  ];

  # For some reason these fail when mpi support is enabled, due to concurrent
  # writings. There are a few open issues about this in the bug tracker, but
  # not related to the tests.
  disabledTests = lib.optionals mpiSupport [ "TestPageBuffering" ];
  pyproject = true;
  pythonImportsCheck = [ "h5py" ];
  pythonRelaxDeps = [ "mpi4py" ];

  passthru = {
    # To evaluate more easily *Support flags of it from within Python Packages.
    inherit hdf5;
  };

  meta = {
    description = "Pythonic interface to the HDF5 binary data format";
    homepage = "http://www.h5py.org/";
    changelog = "https://github.com/h5py/h5py/blob/${version}/docs/whatsnew/${lib.versions.majorMinor version}.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
