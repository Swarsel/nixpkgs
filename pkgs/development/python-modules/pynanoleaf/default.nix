{
  lib,
  buildPythonPackage,
  fetchPypi,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pynanoleaf";
  version = "0.1.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-MqCDdZxPmeAZ4AE2cEh4Qfjt+AfHoHdCqXH6GHBwcqc=";
  };

  # pynanoleaf does not contain tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "pynanoleaf" ];

  meta = {
    description = "Python3 wrapper for the Nanoleaf API, capable of controlling both Nanoleaf Aurora and Nanoleaf Canvas";
    homepage = "https://github.com/Oro/pynanoleaf";
    changelog = "https://github.com/Oro/pynanoleaf/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ oro ];
  };
}
