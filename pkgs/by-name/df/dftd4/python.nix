{
  buildPythonPackage,
  cffi,
  dftd4,
  meson-python,
  ninja,
  numpy,
  pkg-config,
  setuptools,
}:

buildPythonPackage {
  inherit (dftd4)
    pname
    version
    src
    meta
    ;

  nativeBuildInputs = [
    pkg-config
    ninja
  ];

  buildInputs = [ dftd4 ];

  preConfigure = ''
    cd python
  '';

  doCheck = true;

  build-system = [
    meson-python
    setuptools
  ];

  dependencies = [
    cffi
    numpy
  ];

  pyproject = true;
  pythonImportsCheck = [ "dftd4" ];
}
