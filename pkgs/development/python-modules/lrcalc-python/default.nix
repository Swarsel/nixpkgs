{
  lib,
  buildPythonPackage,
  cython,
  fetchPypi,
  lrcalc,
  pkg-config,
}:

buildPythonPackage rec {
  pname = "lrcalc-python";
  version = "2.1";

  src = fetchPypi {
    inherit version;
    sha256 = "e3a0509aeda487b412b391a52e817ca36b5c063a8305e09fd54d53259dd6aaa9";
    pname = "lrcalc";
  };

  nativeBuildInputs = [
    cython
    pkg-config
  ];

  buildInputs = [ lrcalc ];
  format = "setuptools";
  pythonImportsCheck = [ "lrcalc" ];

  meta = {
    description = "Littlewood-Richardson Calculator bindings";
    homepage = "https://sites.math.rutgers.edu/~asbuch/lrcalc/";
    license = lib.licenses.gpl3;
    teams = [ lib.teams.sage ];
  };
}
