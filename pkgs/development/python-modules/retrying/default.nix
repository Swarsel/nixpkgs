{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "retrying";
  version = "1.4.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-0QLnXVPY0wuIVi1FNh1sbJNNoG+rMb2BwEIKy5eoujk=";
  };

  # doesn't ship tests in tarball
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ six ];
  pyproject = true;
  pythonImportsCheck = [ "retrying" ];

  meta = {
    description = "General-purpose retrying library";
    homepage = "https://github.com/rholder/retrying";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
