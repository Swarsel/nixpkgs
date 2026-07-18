{
  lib,
  fetchFromGitHub,
  # propagates
  aiohttp,
  buildPythonPackage,
  # tests
  pytest-asyncio,
  pytestCheckHook,
  # build time
  setuptools-scm,
}:

let
  pname = "uasiren";
  version = "0.0.1";
in

buildPythonPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "PaulAnnekov";
    repo = "uasiren";
    rev = "v${version}";
    hash = "sha256-NHrnG5Vhz+JZgcTJyfIgGz0Ye+3dFVv2zLCCqw2++oM=";
  };

  nativeBuildInputs = [ setuptools-scm ];
  propagatedBuildInputs = [ aiohttp ];

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  format = "setuptools";

  pythonImportsCheck = [
    "uasiren"
    "uasiren.client"
  ];

  meta = {
    description = "Implements siren.pp.ua API - public wrapper for api.ukrainealarm.com API that returns info about Ukraine air-raid alarms";
    homepage = "https://github.com/PaulAnnekov/uasiren";
    changelog = "https://github.com/PaulAnnekov/uasiren/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
