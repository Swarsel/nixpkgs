{
  lib,
  stdenv,
  fetchFromGitHub,
  # dependencies
  array-api-compat,
  biom-format,
  buildPythonPackage,
  # build-system
  cython,
  decorator,
  h5py,
  natsort,
  numpy,
  pandas,
  patsy,
  # tests
  pytestCheckHook,
  python,
  requests,
  scipy,
  setuptools,
  statsmodels,
}:

buildPythonPackage (finalAttrs: {
  pname = "scikit-bio";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "scikit-bio";
    repo = "scikit-bio";
    tag = finalAttrs.version;
    hash = "sha256-zBOUZukqLhTxKG9BluWB+2zTCx5ALhM1s+YP2itqg9A=";
  };

  # The trick above makes test collection fail on darwin:
  # PermissionError: [Errno 1] Operation not permitted: '/nix/.Trashes'
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    cython
    numpy
    setuptools
  ];

  dependencies = [
    array-api-compat
    biom-format
    decorator
    h5py
    natsort
    numpy
    pandas
    patsy
    requests
    scipy
    statsmodels
  ];

  # only the $out dir contains the built cython extensions, so we run the tests inside there
  enabledTestPaths = [ "${placeholder "out"}/${python.sitePackages}/skbio" ];
  pyproject = true;
  pythonImportsCheck = [ "skbio" ];

  meta = {
    description = "Data structures, algorithms and educational resources for bioinformatics";
    homepage = "http://scikit-bio.org/";
    changelog = "https://github.com/scikit-bio/scikit-bio/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ tomasajt ];
    downloadPage = "https://github.com/scikit-bio/scikit-bio";
  };
})
