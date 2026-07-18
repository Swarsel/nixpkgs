{
  lib,
  buildPythonPackage,
  bundlewrap,
  fetchPypi,
  pass,
  setuptools,
}:

buildPythonPackage rec {
  pname = "bundlewrap-pass";
  version = "1.0.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-3KmUTTOQ46TiKXNkKLRweMEe5m/zJ1gvAVJttJBdzik=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    bundlewrap
    pass
  ];

  # upstream has no checks
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "bwpass" ];

  meta = {
    description = "Use secrets from pass in your BundleWrap repo";
    homepage = "https://pypi.org/project/bundlewrap-pass";
    license = lib.licenses.gpl3;
    maintainers = [ ];
  };
}
