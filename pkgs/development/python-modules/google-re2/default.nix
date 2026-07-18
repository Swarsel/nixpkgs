{
  lib,
  buildPythonPackage,
  fetchPypi,
  pybind11,
  re2,
  setuptools,
}:

buildPythonPackage rec {
  pname = "google-re2";
  version = "1.1.20251105";

  src = fetchPypi {
    inherit version;
    hash = "sha256-HbFKKS7oMDuR6R58N+BawX08Rn8pQWx5rHCni+PmW9o=";
    pname = "google_re2";
  };

  buildInputs = [ re2 ];
  doCheck = false; # no tests in sdist
  build-system = [ setuptools ];
  dependencies = [ pybind11 ];
  pyproject = true;
  pythonImportsCheck = [ "re2" ];

  meta = {
    description = "RE2 Python bindings";
    homepage = "https://github.com/google/re2";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ alexbakker ];
  };
}
