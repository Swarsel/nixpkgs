{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "jalali-core";
  version = "1.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-9Ch8cMYwMj3PCjqybfkFuk1FHiMKwfZbO7L3d5eJSis=";
    pname = "jalali_core";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "jalali_core" ];

  meta = {
    description = "Module to convert Gregorian to Jalali and inverse dates";
    homepage = "https://pypi.org/project/jalali-core/";
    license = lib.licenses.lgpl2Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}
