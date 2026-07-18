{
  lib,
  buildPythonPackage,
}:

buildPythonPackage {

  pname = "typeddep";
  version = "1.3.3.7";

  src = lib.fileset.toSource {
    fileset = lib.fileset.unions [
      ./setup.py
      ./typeddep
    ];

    root = ./.;
  };

  format = "setuptools";

}
