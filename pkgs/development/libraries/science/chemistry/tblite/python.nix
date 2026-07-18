{
  blas,
  buildPythonPackage,
  cffi,
  dftd4,
  gfortran,
  lapack,
  mctc-lib,
  meson,
  mstore,
  multicharge,
  ninja,
  numpy,
  pkg-config,
  setuptools,
  simple-dftd3,
  tblite,
  toml-f,
}:

buildPythonPackage {
  inherit (tblite)
    pname
    version
    src
    postPatch
    meta
    ;

  patches = [
    # Add multicharge to the meson deps; otherwise we get missing mod_multicharge errors
    ./0001-fix-multicharge-dep-needed-for-static-compilation.patch
  ];

  nativeBuildInputs = [
    tblite
    meson
    ninja
    pkg-config
    gfortran
    mctc-lib
    setuptools
  ];

  buildInputs = [
    tblite
    simple-dftd3
    blas
    lapack
    mctc-lib
    mstore
    toml-f
    multicharge
    dftd4
  ];

  propagatedBuildInputs = [
    tblite
    simple-dftd3
    cffi
    numpy
  ];

  mesonFlags = [ "-Dpython=true" ];
  pyproject = false;

  pythonImportsCheck = [
    "tblite"
    "tblite.interface"
  ];
}
