{
  lib,
  fetchFromGitHub,
  addDriverRunpath,
  appdirs,
  boost,
  buildPythonPackage,
  cudaPackages,
  decorator,
  fetchPypi,
  mako,
  mkDerivation,
  numpy,
  pytest,
  python,
  pytools,
  six,
}:
let
  compyte = import ./compyte.nix { inherit mkDerivation fetchFromGitHub; };

  inherit (cudaPackages) cudatoolkit;
in
buildPythonPackage rec {
  pname = "pycuda";
  version = "2026.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-dZUWFgYougbzLOflY+P1uSFGkdyVKKA+qZ6hBz9OFLo=";
  };

  nativeBuildInputs = [ addDriverRunpath ];

  propagatedBuildInputs = [
    numpy
    pytools
    pytest
    decorator
    appdirs
    six
    cudatoolkit
    compyte
    python
    mako
  ];

  preConfigure = with lib.versions; ''
    ${python.pythonOnBuildForHost.interpreter} configure.py --boost-inc-dir=${boost.dev}/include \
                          --boost-lib-dir=${boost}/lib \
                          --no-use-shipped-boost \
                          --boost-python-libname=boost_python${major python.version}${minor python.version} \
                          --cuda-root=${cudatoolkit}
  '';

  # Requires access to libcuda.so.1 which is provided by the driver
  doCheck = false;

  checkPhase = ''
    py.test
  '';

  postInstall = ''
    ln -s ${compyte} $out/${python.sitePackages}/pycuda/compyte
  '';

  postFixup = ''
    find $out/lib -type f \( -name '*.so' -or -name '*.so.*' \) | while read lib; do
      echo "setting opengl runpath for $lib..."
      addDriverRunpath "$lib"
    done
  '';

  format = "setuptools";

  meta = {
    description = "CUDA integration for Python";
    homepage = "https://github.com/inducer/pycuda/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
