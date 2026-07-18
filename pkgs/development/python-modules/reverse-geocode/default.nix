{
  lib,
  buildPythonPackage,
  fetchPypi,
  numpy,
  scipy,
  setuptools,
}:

buildPythonPackage rec {
  pname = "reverse-geocode";
  version = "1.6.6";

  src = fetchPypi {
    inherit version;
    hash = "sha256-FBZYFYFsxjnddOtmCnTkZK7rzR0IFN50qJfWIHHJnyo=";
    pname = "reverse_geocode";
  };

  #
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    numpy
    scipy
  ];

  pyproject = true;
  pythonImportsCheck = [ "reverse_geocode" ];

  meta = {
    description = "Reverse geocode the given latitude/longitude";
    homepage = "https://pypi.org/project/reverse-geocode/";
    license = lib.licenses.lgpl2Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}
