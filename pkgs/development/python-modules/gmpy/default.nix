{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gmp,
  isPyPy,
  pythonAtLeast,
  setuptools,
}:

buildPythonPackage rec {
  pname = "gmpy";
  version = "2.2.2";

  src = fetchFromGitHub {
    owner = "aleaxit";
    repo = "gmpy";
    tag = "v${version}";
    hash = "sha256-joeHec/d82sovfASCU3nlNL6SaThnS/XYPqujiZ9h8s=";
  };

  buildInputs = [ gmp ];
  build-system = [ setuptools ];
  # Python 3.11 has finally made changes to its C API for which gmpy 1.17,
  # published in 2013, would require patching. It seems unlikely that any
  # patches will be forthcoming.
  disabled = isPyPy || pythonAtLeast "3.11";
  pyproject = true;
  pythonImportsCheck = [ "gmpy" ];

  meta = {
    description = "GMP or MPIR interface to Python 2.4+ and 3.x";
    homepage = "https://github.com/aleaxit/gmpy/";
    license = lib.licenses.lgpl21Plus;
  };
}
