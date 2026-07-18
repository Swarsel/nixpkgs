{
  buildPythonPackage,
  cmake,
  elastix,
  itk,
  numpy,
  scikit-build,
  simpleitk,
  swig,
}:

buildPythonPackage rec {
  inherit (simpleitk)
    pname
    version
    src
    meta
    ;

  nativeBuildInputs = [
    cmake
    swig
    scikit-build
  ];

  propagatedBuildInputs = [
    elastix
    itk
    simpleitk
    numpy
  ];

  preBuild = ''
    make
  '';

  pyproject = true;
  pythonImportsCheck = [ "SimpleITK" ];
  sourceRoot = "${src.name}/Wrapping/Python";
}
