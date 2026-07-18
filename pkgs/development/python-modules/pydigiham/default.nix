{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  codecserver,
  digiham,
  pycsdr,
  python,
}:

buildPythonPackage rec {
  pname = "pydigiham";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "jketterl";
    repo = "pydigiham";
    rev = version;
    hash = "sha256-QenoMyVFs8MEDPoMV6TT6XfzktfN/gAMIHR0Scq11wk=";
  };

  buildInputs = [
    codecserver
    pycsdr
  ];

  propagatedBuildInputs = [ digiham ];

  # make pycsdr header files available
  preBuild = ''
    ln -s ${pycsdr}/include/${python.libPrefix}/pycsdr src/pycsdr
  '';

  # has no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "digiham" ];

  meta = {
    description = "Bindings for the csdr library";
    homepage = "https://github.com/jketterl/pydigiham";
    license = lib.licenses.gpl3Only;
  };
}
