{
  lib,
  fetchFromGitHub,
  # dependencies
  asgiref,
  buildPythonPackage,
  httpx,
  pydantic,
  # tests
  pytest-asyncio,
  pytestCheckHook,
  requests,
  responses,
  respx,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "mixpanel";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "mixpanel";
    repo = "mixpanel-python";
    tag = "v${version}";
    hash = "sha256-Q8Kn2dyID1hYjKmEv0e+R/y5dsp/JEkqCdNqQHJsOrI=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
    responses
    respx
  ];

  build-system = [ setuptools ];

  dependencies = [
    asgiref
    httpx
    pydantic
    requests
  ];

  pyproject = true;

  meta = {
    description = "Official Mixpanel Python library";
    homepage = "https://github.com/mixpanel/mixpanel-python";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ kamadorueda ];
  };
}
