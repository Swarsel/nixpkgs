{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pytestCheckHook,
  requests,
  setuptools,
  websocket-client,
}:

buildPythonPackage rec {
  pname = "py-dactyl";
  version = "2.1.2";

  src = fetchFromGitHub {
    owner = "iamkubi";
    repo = "pydactyl";
    tag = "v${version}";
    hash = "sha256-/bmk4RIS8pEi+RbJ+6tOchwFj246hdoTXv6WBNisKuc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    requests
    websocket-client
  ];

  disabledTests = [
    # upstream's tests are not fully maintained
    "test_paginated_response_multipage_iterator"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pydactyl" ];

  meta = {
    description = "Python wrapper for the Pterodactyl Panel API";
    homepage = "https://github.com/iamkubi/pydactyl";
    changelog = "https://github.com/iamkubi/pydactyl/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
