{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "fprettify";
  version = "0.3.7";

  src = fetchFromGitHub {
    owner = "fortran-lang";
    repo = "fprettify";
    rev = "v${finalAttrs.version}";
    sha256 = "17v52rylmsy3m3j5fcb972flazykz2rvczqfh8mxvikvd6454zyj";
  };

  preConfigure = ''
    patchShebangs fprettify.py
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    configargparse
  ];

  pyproject = true;

  meta = {
    description = "Auto-formatter for modern Fortran code that imposes strict whitespace formatting, written in Python";
    homepage = "https://pypi.org/project/fprettify/";
    license = with lib.licenses; [ gpl3Only ];
    maintainers = [ ];
    mainProgram = "fprettify";
  };
})
