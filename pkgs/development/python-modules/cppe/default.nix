{
  lib,
  stdenv,
  buildPythonPackage,
  cmake,
  cppe,
  eigen,
  h5py,
  llvmPackages,
  numba,
  numpy,
  pandas,
  polarizationsolver,
  pybind11,
  pytest,
  scipy,
}:

buildPythonPackage {
  inherit (cppe)
    pname
    version
    src
    meta
    ;

  # The python interface requires eigen3, but builds from a checkout in tree.
  # Using the nixpkgs version instead.
  postPatch = ''
    substituteInPlace setup.py \
      --replace "external/eigen3" "${eigen}/include/eigen3"
  '';

  nativeBuildInputs = [
    cmake
    eigen
  ];

  buildInputs = [ pybind11 ] ++ lib.optional stdenv.cc.isClang llvmPackages.openmp;

  env = lib.optionalAttrs stdenv.cc.isClang {
    NIX_CFLAGS_LINK = "-lomp";
  };

  nativeCheckInputs = [
    pytest
    h5py
    numba
    numpy
    pandas
    polarizationsolver
    scipy
  ];

  dontUseCmakeConfigure = true;
  format = "setuptools";
  hardeningDisable = lib.optional stdenv.cc.isClang "strictoverflow";
  pythonImportsCheck = [ "cppe" ];
}
