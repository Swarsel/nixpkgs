{
  lib,
  buildPythonPackage,
  furo,
  jupyter-sphinx,
  sage-src,
  sphinx,
  sphinx-copybutton,
  sphinx-inline-tabs,
}:

buildPythonPackage rec {
  pname = "sage-docbuild";
  version = src.version;
  src = sage-src;

  propagatedBuildInputs = [
    furo
    jupyter-sphinx
    sphinx
    sphinx-copybutton
    sphinx-inline-tabs
  ];

  preBuild = ''
    cd pkgs/sage-docbuild
  '';

  doCheck = false; # we will run tests in sagedoc.nix
  format = "setuptools";

  meta = {
    description = "Build system of the Sage documentation";
    homepage = "https://www.sagemath.org";
    license = lib.licenses.gpl2Plus;
    teams = [ lib.teams.sage ];
  };
}
