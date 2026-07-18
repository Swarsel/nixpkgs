{
  lib,
  asgiref,
  buildPythonPackage,
  fetchPypi,
  poetry-core,
}:

buildPythonPackage rec {
  pname = "asgi-logger";
  version = "0.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-son1ML9J0UMgJCpWdYD/yK0FO6VmfuzifSWpeCLToKo=";
  };

  nativeBuildInputs = [ poetry-core ];
  propagatedBuildInputs = [ asgiref ];
  # tests are not in the pypi release, and there are no tags/release corresponding to the pypi releases in the github
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "asgi_logger" ];

  meta = {
    description = "Access logger for ASGI servers";
    homepage = "https://github.com/Kludex/asgi-logger";
    license = lib.licenses.mit;
  };
}
