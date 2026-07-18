{
  lib,
  buildPythonPackage,
  cmake,
  flit-core,
}:

buildPythonPackage {
  inherit (cmake) version;
  inherit (cmake) setupHooks;
  pname = "cmake";
  src = ./stub;
  nativeBuildInputs = [ flit-core ];

  postUnpack = ''
    substituteInPlace "$sourceRoot/pyproject.toml" \
      --subst-var version

    substituteInPlace "$sourceRoot/cmake/__init__.py" \
      --subst-var version \
      --subst-var-by CMAKE_BIN_DIR "${cmake}/bin"
  '';

  pyproject = true;
  pythonImportsCheck = [ "cmake" ];

  meta = {
    description = "CMake is an open-source, cross-platform family of tools designed to build, test and package software";

    longDescription = ''
      This is a stub of the cmake package on PyPI that uses the cmake program
      provided by nixpkgs instead of downloading cmake from the web.
    '';

    homepage = "https://github.com/scikit-build/cmake-python-distributions";
    license = lib.licenses.asl20;
  };
}
