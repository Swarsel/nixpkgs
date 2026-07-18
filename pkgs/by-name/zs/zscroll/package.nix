{
  lib,
  fetchFromGitHub,
  python3,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "zscroll";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "noctuid";
    repo = "zscroll";
    rev = finalAttrs.version;
    sha256 = "sha256-gEluWzCbztO4N1wdFab+2xH7l9w5HqZVzp2LrdjHSRM=";
  };

  propagatedBuildInputs = [ python3 ];
  doCheck = false;
  format = "setuptools";
  # don't prefix with python version
  namePrefix = "";

  meta = {
    description = "Text scroller for use with panels and shells";
    homepage = "https://github.com/noctuid/zscroll";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.all;
    mainProgram = "zscroll";
  };
})
