{
  lib,
  beautifulsoup4,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "google";
  version = "3.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-FDUwEi7lEwUJrV6YnwUS98shiy1O3br7rUD9EOjYzL4=";
  };

  propagatedBuildInputs = [ beautifulsoup4 ];
  # Module has no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "googlesearch" ];

  meta = {
    description = "Python bindings to the Google search engine";
    homepage = "https://pypi.org/project/google/";
    license = with lib.licenses; [ bsd3 ];
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "google";
  };
}
