{
  lib,
  beautifulsoup4,
  buildPythonPackage,
  fetchPypi,
  requests,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "feedfinder2";
  version = "0.0.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-NwHuAabIX4uGWgScMLoLRgiFjIA/6OMNHSif2+idDv4=";
  };

  # no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    six
    requests
    beautifulsoup4
  ];

  pyproject = true;
  pythonImportsCheck = [ "feedfinder2" ];

  meta = {
    description = "Python library for finding feed links on websites";
    homepage = "https://github.com/dfm/feedfinder2";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vizid ];
  };
}
