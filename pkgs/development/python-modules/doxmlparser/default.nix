{
  buildPythonPackage,
  doxygen,
  lxml,
  setuptools,
  six,
}:
buildPythonPackage rec {
  inherit (doxygen) version src;
  pname = "doxmlparser";
  build-system = [ setuptools ];

  dependencies = [
    lxml
    six
  ];

  format = "setuptools";
  pythonImportsCheck = [ "doxmlparser" ];
  sourceRoot = "${src.name}/addon/doxmlparser";

  meta = {
    inherit (doxygen.meta)
      license
      homepage
      changelog
      platforms
      ;

    description = "Library to parse the XML output produced by doxygen";
  };
}
