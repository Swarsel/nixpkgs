{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "crashtest";
  version = "0.4.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-gNex8xbr+9Qp9kgHbWJ1yHe6MLpIl53kGRcUp1Jm8M4=";
  };

  format = "setuptools";

  # has tests, but only on GitHub, however the pyproject build fails for me
  pythonImportsCheck = [
    "crashtest.frame"
    "crashtest.inspector"
  ];

  meta = {
    description = "Manage Python errors with ease";
    homepage = "https://github.com/sdispater/crashtest";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
