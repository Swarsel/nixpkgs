{
  lib,
  buildPythonPackage,
  fetchPypi,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "jsonfeed";
  version = "0.0.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Etfi59oOCrLHavLRMQo3HASFnydrBnsyEtGUgcsv1aQ=";
  };

  postPatch = ''
    # Mixing of dev and runtime requirements
    substituteInPlace setup.py \
      --replace-fail "install_requires=install_requires," "install_requires=[],"
  '';

  # Module has no tests, only a placeholder
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "jsonfeed" ];

  meta = {
    description = "Module to process json feed";
    homepage = "https://pypi.org/project/jsonfeed/";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ fab ];
  };
}
