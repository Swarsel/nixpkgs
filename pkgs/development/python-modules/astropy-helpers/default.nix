{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "astropy-helpers";
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "astropy";
    repo = "astropy-helpers";
    tag = "v${version}";
    hash = "sha256-MjL/I+ApyoyoD2NmKuKWpDbyuEgvBb2OBhxqj/w/3lk=";
  };

  patches = [
    # Fixes build with Python 3.12+
    ./python-imp.patch
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "astropy_helpers" ];

  meta = {
    description = "Utilities for building and installing Astropy, Astropy affiliated packages, and their respective documentation";
    homepage = "https://github.com/astropy/astropy-helpers";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.smaret ];
  };
}
