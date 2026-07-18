{
  lib,
  stdenv,
  # fetchers
  fetchFromGitHub,
  boost,
  build,
  buildPythonPackage,
  cgal_5,
  # build tools
  cmake,
  # native dependencies
  eigen,
  fetchpatch,
  gitUpdater,
  gmp,
  hdf5,
  icu,
  ## additional deps for tests
  ifcopenshell,
  ## dependencies
  isodate,
  lark,
  libaec,
  libxml2,
  lxml,
  mathutils,
  mpfr,
  networkx,
  nlohmann_json,
  numpy,
  opencascade-occt_7_6,
  pytest,
  pytestCheckHook,
  python,
  python-dateutil,
  # python deps
  ## tools
  setuptools,
  shapely,
  swig,
  tabulate,
  testers,
  typing-extensions,
  xmlschema,
  xsdata,
  zlib,
}:
let
  opencascade-occt = opencascade-occt_7_6;
in
buildPythonPackage rec {
  pname = "ifcopenshell";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "IfcOpenShell";
    repo = "IfcOpenShell";
    tag = "ifcopenshell-python-${version}";
    hash = "sha256-tnj14lBEkUZNDM9J1sRhNA7OkWTWa5JPTSF8hui3q7k=";
    fetchSubmodules = true;
  };

  patches = [
    (fetchpatch {
      hash = "sha256-oZDEL8cPcEu83lW+qSvCbmDGYpaNNRrptW9MLu2pN70=";
      name = "ifcopenshell-boost-1.86-mt19937.patch";
      url = "https://github.com/IfcOpenShell/IfcOpenShell/commit/1fe168d331123920eeb9a96e542fcc1453de57fe.patch";
    })

    (fetchpatch {
      hash = "sha256-zMoQcBWRdtavL0xdsr53SqyG6CZoeon8/mmJhrw85lc=";
      name = "ifcopenshell-boost-1.86-json.patch";
      url = "https://github.com/IfcOpenShell/IfcOpenShell/commit/88b861737c7c206d0e7307f90d37467e9585515c.patch";
    })
  ];

  postPatch = ''
    pushd src/ifcopenshell-python
    # The build process is here: https://github.com/IfcOpenShell/IfcOpenShell/blob/v0.8.0/src/ifcopenshell-python/Makefile#L131
    # NOTE: it has changed a *lot* between 0.7.0 and 0.8.0, it *may* change again (look for mathutils and basically all the things this Makefile does manually)
    substituteInPlace pyproject.toml --replace-fail "0.0.0" "${version}"
    # NOTE: the following is directly inspired by https://github.com/IfcOpenShell/IfcOpenShell/blob/v0.8.0/src/ifcopenshell-python/Makefile#L123
    cp ../../README.md README.md
    popd

    # boost189 compatibility; see https://www.boost.org/releases/1.89.0/
    substituteInPlace cmake/CMakeLists.txt \
      --replace-fail 'set(BOOST_COMPONENTS system' 'set(BOOST_COMPONENTS'
  '';

  nativeBuildInputs = [
    # c++
    cmake
    swig
    # python
    build
    setuptools
  ];

  buildInputs = [
    # ifcopenshell needs stdc++
    (lib.getLib stdenv.cc.cc)
    boost
    cgal_5
    eigen
    gmp
    hdf5
    icu
    libaec
    libxml2
    mpfr
    nlohmann_json
    opencascade-occt
  ];

  propagatedBuildInputs = [
    isodate
    lark
    numpy
    python-dateutil
    shapely
    typing-extensions
  ];

  # We still build with python to generate ifcopenshell_wrapper.py and ifcopenshell_wrapper.so
  cmakeFlags = [
    "-DUSERSPACE_PYTHON_PREFIX=ON"
    "-DBUILD_SHARED_LIBS=ON"
    "-DBUILD_IFCPYTHON=ON"
    "-DCITYJSON_SUPPORT=OFF"
    "-DCOLLADA_SUPPORT=OFF"
    "-DEIGEN_DIR=${eigen}/include/eigen3"
    "-DJSON_INCLUDE_DIR=${nlohmann_json}/include/"
    "-DOCC_INCLUDE_DIR=${opencascade-occt}/include/opencascade"
    "-DOCC_LIBRARY_DIR=${lib.getLib opencascade-occt}/lib"
    "-DSWIG_EXECUTABLE=${swig}/bin/swig"
    "-DLIBXML2_INCLUDE_DIR=${libxml2.dev}/include/libxml2"
    "-DLIBXML2_LIBRARIES=${lib.getLib libxml2}/lib/libxml2${stdenv.hostPlatform.extensions.sharedLibrary}"
    "-DGMP_LIBRARY_DIR=${lib.getLib gmp}/lib/"
    "-DMPFR_LIBRARY_DIR=${lib.getLib mpfr}/lib/"
    # HDF5 support is currently not optional, see https://github.com/IfcOpenShell/IfcOpenShell/issues/1815
    "-DHDF5_SUPPORT=ON"
    "-DHDF5_INCLUDE_DIR=${hdf5.dev}/include/"
    "-DHDF5_LIBRARIES=${lib.getLib hdf5}/lib/libhdf5_cpp.so;${lib.getLib hdf5}/lib/libhdf5.so;${lib.getLib zlib}/lib/libz.so;${lib.getLib libaec}/lib/libaec.so;"
  ];

  env.PYTHONUSERBASE = ".";

  preConfigure = ''
    cd cmake
  '';

  # list taken from .github/workflows/ci.yml:49
  nativeCheckInputs = [
    lxml
    mathutils
    networkx
    pytest
    tabulate
    xmlschema
    xsdata

    pytestCheckHook
  ];

  preCheck = ''
    pushd ../../src/ifcopenshell-python
    # let's test like done in .github/workflows/ci.yml
    # installing the python wrapper and the .so, both are needed to be able to test
    cp -v $out/${python.sitePackages}/ifcopenshell/ifcopenshell_wrapper.py ./ifcopenshell
    cp $out/${python.sitePackages}/ifcopenshell/_ifcopenshell_wrapper.cpython-${
      lib.versions.major python.version + lib.versions.minor python.version
    }-${stdenv.targetPlatform.system}-gnu.so ./ifcopenshell
    pushd ../../test
    PYTHONPATH=../src/ifcopenshell-python/ python tests.py
    popd
  '';

  postCheck = ''
    popd
  '';

  disabledTestPaths = [
    "test/test_open.py"
  ];

  pyproject = false;

  pytestFlags = [
    "-pno:pytest-blender"
  ];

  pythonImportsCheck = [ "ifcopenshell" ];

  passthru = {
    tests = {
      version = testers.testVersion {
        command = "IfcConvert --version";
        package = ifcopenshell;
      };
    };

    updateScript = gitUpdater { rev-prefix = "ifcopenshell-python-"; };
  };

  meta = {
    description = "Open source IFC library and geometry engine";
    homepage = "https://ifcopenshell.org/";
    license = lib.licenses.lgpl3;
    broken = stdenv.hostPlatform.isDarwin;
    teams = [ lib.teams.geospatial ];
  };
}
