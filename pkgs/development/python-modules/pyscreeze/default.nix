{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  pillow,
  python-xlib,
  scrot,
  xvfb-run,
}:
buildPythonPackage {
  pname = "pyscreeze";
  version = "0.1.26";

  src = fetchFromGitHub {
    owner = "asweigart";
    repo = "pyscreeze";
    rev = "28ab707dceecbdd135a9491c3f8effd3a69680af";
    hash = "sha256-gn3ydjf/msdhIhngGlhK+jhEyFy0qGeDr58E7kM2YZs=";
  };

  propagatedBuildInputs = [ pillow ];
  doCheck = stdenv.hostPlatform.isLinux;

  nativeCheckInputs = lib.optionals stdenv.hostPlatform.isLinux [
    scrot
    python-xlib
    xvfb-run
  ];

  checkPhase = lib.optionalString stdenv.hostPlatform.isLinux ''
    python -m unittest tests.test_pillow_unavailable
    xvfb-run python -m unittest tests.test_pyscreeze
  '';

  format = "setuptools";
  pythonImportsCheck = [ "pyscreeze" ];

  meta = {
    description = "PyScreeze is a simple, cross-platform screenshot module for Python 2 and 3";
    homepage = "https://github.com/asweigart/pyscreeze";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
