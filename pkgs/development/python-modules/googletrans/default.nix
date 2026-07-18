{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  httpx,
}:

buildPythonPackage rec {
  pname = "googletrans";
  version = "4.0.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-2e8Sa12S+r7sC7ndzb7s1Dhl/ADhfx36B3F4N4J6F94=";
  };

  # Majority of tests just try to ping Google's Translate API endpoint
  doCheck = false;
  build-system = [ hatchling ];
  dependencies = [ httpx ] ++ httpx.optional-dependencies.http2;
  pyproject = true;
  pythonImportsCheck = [ "googletrans" ];

  meta = {
    description = "Library to interact with Google Translate API";
    homepage = "https://py-googletrans.readthedocs.io";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ unode ];
    mainProgram = "translate";
  };
}
