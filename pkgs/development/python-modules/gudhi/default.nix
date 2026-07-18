{
  lib,
  fetchFromGitHub,
  boost,
  buildPythonPackage,
  cgal,
  cmake,
  cython,
  eigen,
  gmp,
  matplotlib,
  mpfr,
  numpy,
  onetbb,
  pybind11,
  pytest,
  scipy,
  setuptools,
  enableTBB ? false,
}:

buildPythonPackage rec {
  pname = "gudhi";
  version = "3.11.0";

  src = fetchFromGitHub {
    owner = "GUDHI";
    repo = "gudhi-devel";
    tag = "tags/gudhi-release-${version}";
    hash = "sha256-EebPvmioTYBv3VR6SNEfiqi2GC4sZn8WEj0fu42B8yM=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    numpy
    cython
    pybind11
    matplotlib
    setuptools
  ];

  buildInputs = [
    boost
    eigen
    gmp
    cgal
    mpfr
  ]
  ++ lib.optionals enableTBB [ onetbb ];

  propagatedBuildInputs = [
    numpy
    scipy
  ];

  cmakeFlags = [
    (lib.cmakeBool "WITH_GUDHI_PYTHON" true)
    (lib.cmakeFeature "Python_ADDITIONAL_VERSIONS" "3")
  ];

  preBuild = ''
    cd src/python
  '';

  nativeCheckInputs = [ pytest ];

  checkPhase = ''
    runHook preCheck

    rm -r gudhi
    ctest --output-on-failure

    runHook postCheck
  '';

  prePatch = ''
    substituteInPlace src/python/CMakeLists.txt \
      --replace '"''${GUDHI_PYTHON_PATH_ENV}"' ""
  '';

  pyproject = true;

  pythonImportsCheck = [
    "gudhi"
    "gudhi.hera"
    "gudhi.point_cloud"
    "gudhi.clustering"
  ];

  meta = {
    description = "Library for Computational Topology and Topological Data Analysis (TDA)";
    homepage = "https://gudhi.inria.fr/python/latest/";

    license = with lib.licenses; [
      mit
      gpl3
    ];

    maintainers = with lib.maintainers; [ yl3dy ];
    downloadPage = "https://github.com/GUDHI/gudhi-devel";
  };
}
