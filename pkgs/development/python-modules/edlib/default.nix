{
  buildPythonPackage,
  cython,
  edlib,
  python,
  setuptools,
}:

buildPythonPackage {
  inherit (edlib)
    pname
    src
    version
    meta
    ;

  buildInputs = [ edlib ];
  env.EDLIB_OMIT_README_RST = 1;
  env.EDLIB_USE_CYTHON = 1;

  preBuild = ''
    ln -s ${edlib.src}/edlib .
  '';

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} test.py
    runHook postCheck
  '';

  build-system = [
    setuptools
    cython
  ];

  pyproject = true;
  pythonImportsCheck = [ "edlib" ];
  sourceRoot = "${edlib.src.name}/bindings/python";
}
