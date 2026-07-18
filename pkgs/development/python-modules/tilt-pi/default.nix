{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  poetry-core,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "tilt-pi";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "michaelheyman";
    repo = "tilt-pi";
    tag = "v${version}";
    hash = "sha256-jGy7nwSblF486ldt4ShBEmmZtb0c4+7IuI10cN7Bw1A=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
  ];

  pyproject = true;
  pythonImportsCheck = [ "tiltpi" ];

  meta = {
    description = "Python client for interacting with the Tilt Pi API";
    homepage = "https://github.com/michaelheyman/tilt-pi";
    changelog = "https://github.com/michaelheyman/tilt-pi/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
