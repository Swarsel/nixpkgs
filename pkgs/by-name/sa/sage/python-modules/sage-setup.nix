{
  lib,
  buildPythonPackage,
  cython,
  jinja2,
  pkgconfig, # the python module, not the pkg-config alias
  sage-src,
}:

buildPythonPackage rec {
  pname = "sage-setup";
  version = src.version;
  src = sage-src;
  nativeBuildInputs = [ cython ];
  buildInputs = [ pkgconfig ];
  propagatedBuildInputs = [ jinja2 ];

  preBuild = ''
    cd pkgs/sage-setup
  '';

  doCheck = false; # sagelib depends on sage-setup, but sage-setup's tests depend on sagelib
  format = "setuptools";

  meta = {
    description = "Build system of the Sage library";
    homepage = "https://www.sagemath.org";
    license = lib.licenses.gpl2Plus;
    teams = [ lib.teams.sage ];
  };
}
