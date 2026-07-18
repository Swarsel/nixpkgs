{
  lib,
  stdenv,
  fetchFromGitLab,
  # dependencies
  astropy,
  buildPythonPackage,
  ducc0,
  h5py,
  jax,
  jaxlib,
  matplotlib,
  mpi,
  mpi4py,
  mpiCheckPhaseHook,
  numpy,
  openssh,
  pytest-xdist,
  # test
  pytestCheckHook,
  scipy,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "nifty8";
  version = "8.5.7";

  src = fetchFromGitLab {
    owner = "ift";
    repo = "nifty";
    tag = "v${version}";
    hash = "sha256-5KPmM1UaXnS/ZEsnyFyxvDk4Nc4m6AT5FDgmCG6U6YU=";
    domain = "gitlab.mpcdf.mpg.de";
  };

  # nifty8.re is the jax-backed version of nifty8 (the regular one uses numpy).
  # It is not compatible with the latest jax update:
  # https://gitlab.mpcdf.mpg.de/ift/nifty/-/issues/414
  # While the issue is being fixed by upstream, we completely remove this package from the source and the tests.
  postPatch = ''
    rm -r src/re
    rm -r test/test_re
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-xdist
    mpiCheckPhaseHook
    openssh
  ];

  # Prevents 'Fatal Python error: Aborted' on darwin during checkPhase
  preCheck = lib.optionalString stdenv.hostPlatform.isDarwin ''
    export MPLBACKEND="Agg"
  '';

  postCheck =
    lib.optionalString
      (
        # Fails on aarch64-linux with:
        # hwloc/linux: failed to find sysfs cpu topology directory, aborting linux discovery.
        # All nodes which are allocated for this job are already filled.
        !(stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64)
      )
      ''
        ${lib.getExe' mpi "mpirun"} -n 2 --bind-to none python3 -m pytest test/test_mpi
      '';

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    astropy
    ducc0
    h5py
    jax
    jaxlib
    matplotlib
    mpi4py
    mpi
    numpy
    scipy
  ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # [XPASS(strict)] np.vdot inaccurate for single precision
    "test_vdot"
  ];

  pyproject = true;
  pythonImportsCheck = [ "nifty8" ];

  meta = {
    description = "Bayesian Imaging library for high-dimensional posteriors";

    longDescription = ''
      NIFTy, "Numerical Information Field Theory", is a Bayesian imaging library.
      It is designed to infer the million to billion dimensional posterior
      distribution in the image space from noisy input data.  At the core of
      NIFTy lies a set of powerful Gaussian Process (GP) models and accurate
      Variational Inference (VI) algorithms.
    '';

    homepage = "https://gitlab.mpcdf.mpg.de/ift/nifty";
    changelog = "https://gitlab.mpcdf.mpg.de/ift/nifty/-/blob/v${version}/ChangeLog.md";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ parras ];
  };
}
