{
  ase,
  buildPythonPackage,
  cffi,
  meson,
  meson-python,
  numpy,
  pkg-config,
  pyscf,
  pytestCheckHook,
  python,
  qcengine,
  setuptools,
  simple-dftd3,
  toml,
}:

buildPythonPackage {
  inherit (simple-dftd3)
    pname
    version
    src
    meta
    ;

  nativeBuildInputs = [
    pkg-config
    meson
  ];

  buildInputs = [ simple-dftd3 ];

  preConfigure = ''
    cd python
  '';

  doCheck = true;

  checkInputs = [
    ase
    qcengine
    pyscf
    pytestCheckHook
  ];

  # The compiled CFFI is not placed correctly before pytest invocation
  preCheck = ''
    find . -name "_libdftd3*" -exec cp {} ./dftd3/. \;
  '';

  # Parameters need to be present in the python site packages directory, but they
  # are originally only present in the fortran package. This is a consequence of
  # building the python bindings separately from the fortran library.
  postInstall = ''
    ln -s ${simple-dftd3}/share/s-dftd3/parameters.toml $out/${python.sitePackages}/dftd3/.
  '';

  build-system = [
    meson-python
    setuptools
  ];

  dependencies = [
    cffi
    numpy
    toml
  ];

  pyproject = true;
  pythonImportsCheck = [ "dftd3" ];
}
