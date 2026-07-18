{
  lib,
  stdenv,
  fetchFromGitHub,
  astunparse,
  buildPythonPackage,
  cython,
  fetchpatch,
  gsd,
  llvmPackages,
  netcdf4,
  networkx,
  numpy,
  packaging,
  pandas,
  pyparsing,
  pytest-xdist,
  pytestCheckHook,
  pythonAtLeast,
  scipy,
  setuptools,
  tables,
  versioneer,
  wheel,
  zlib,
}:

buildPythonPackage rec {
  pname = "mdtraj";
  version = "1.11.1";

  src = fetchFromGitHub {
    owner = "mdtraj";
    repo = "mdtraj";
    tag = version;
    hash = "sha256-xSXfV/lrUy33RSOpz3FsX5HP1Wr84rKCYmEKNVVnQao=";
  };

  patches = [
    # disable intrinsics when SIMD is not available
    # TODO: enable SIMD with python3.12
    # https://github.com/mdtraj/mdtraj/pull/1884
    (fetchpatch {
      hash = "sha256-kcnlHMoA/exJzV8iQltH+LWXrvSk7gsUV+yWK6xn0jg=";
      name = "fix-intrinsics-flag.patch";
      url = "https://github.com/mdtraj/mdtraj/commit/d6041c645d51898e2a09030633210213eec7d4c5.patch";
    })
  ];

  buildInputs = [ zlib ] ++ lib.optionals stdenv.cc.isClang [ llvmPackages.openmp ];
  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Wno-incompatible-function-pointer-types";

  nativeCheckInputs = [
    gsd
    networkx
    pandas
    pytest-xdist
    pytestCheckHook
    tables
  ];

  preCheck = ''
    cd tests
    export PATH=$out/bin:$PATH
  '';

  build-system = [
    cython
    numpy
    setuptools
    versioneer
    wheel
  ];

  dependencies = [
    netcdf4
    numpy
    packaging
    pyparsing
    scipy
  ];

  # these files import distutils
  # remove once https://github.com/mdtraj/mdtraj/pull/1916 is merged
  disabledTestPaths = lib.optionals (pythonAtLeast "3.12") [
    "test_mol2.py"
    "test_netcdf.py"
  ];

  disabledTests = [
    # require network access
    "test_load_pdb_from_url"
    "test_load_from_url"
    "test_1vii_url_and_gz"
    "test_1vii_load_from_mixture"
    "test_3"

    # fail due to data race
    "test_read_atomindices_1"
    "test_read_atomindices_2"

    # flaky test
    "test_compare_rdf_t_master"
    "test_distances_t"
    "test_precentered_2"
  ];

  pyproject = true;
  pythonImportsCheck = [ "mdtraj" ];

  meta = {
    description = "Open library for the analysis of molecular dynamics trajectories";
    homepage = "https://github.com/mdtraj/mdtraj";
    changelog = "https://github.com/mdtraj/mdtraj/releases/tag/${src.tag}";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ natsukium ];
  };
}
