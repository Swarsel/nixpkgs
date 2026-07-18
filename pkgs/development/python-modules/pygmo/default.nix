{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cloudpickle,
  cmake,
  ipyparallel,
  numba,
  numpy,
  pagmo2,
  pybind11,
  python,
  toPythonModule,
}:

toPythonModule (
  stdenv.mkDerivation rec {
    pname = "pygmo";
    version = "2.19.7";

    src = fetchFromGitHub {
      owner = "esa";
      repo = "pygmo2";
      tag = "v${version}";
      hash = "sha256-279KNnP11f5ob2senIVmbnlmhRp2p3RoZLsQRE6yJ5Q=";
    };

    nativeBuildInputs = [ cmake ];

    buildInputs = [
      boost
      pagmo2
      pybind11
    ];

    propagatedBuildInputs = [
      cloudpickle
      ipyparallel
      numba
      numpy
      python
    ];

    cmakeFlags = [ "-DPYGMO_INSTALL_PATH=${placeholder "out"}/${python.sitePackages}" ];
    doCheck = true;

    meta = {
      description = "Parallel optimisation for Python";
      homepage = "https://github.com/esa/pygmo2";
      license = lib.licenses.gpl3Plus;
      maintainers = [ ];
    };
  }
)
