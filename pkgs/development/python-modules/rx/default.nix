{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "rx";
  version = "3.2.0";

  # Use fetchPypi to avoid the updater script to migrate it to `reactivex` which
  # is being developed in the same repository
  src = fetchPypi {
    inherit version;
    sha256 = "b657ca2b45aa485da2f7dcfd09fac2e554f7ac51ff3c2f8f2ff962ecd963d91c";
    pname = "Rx";
  };

  doCheck = false; # PyPI tarball does not provides tests
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "rx" ];

  meta = {
    description = "Reactive Extensions for Python";
    homepage = "https://github.com/ReactiveX/RxPY";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ thanegill ];
  };
}
