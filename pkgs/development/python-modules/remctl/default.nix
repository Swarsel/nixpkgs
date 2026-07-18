{
  buildPythonPackage,
  remctl-c, # remctl from pkgs, not from pythonPackages
}:

buildPythonPackage {
  inherit (remctl-c)
    meta
    pname
    src
    version
    ;

  buildInputs = [ remctl-c ];
  format = "setuptools";
  setSourceRoot = "sourceRoot=$(echo */python)";
}
