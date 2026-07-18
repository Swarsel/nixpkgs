{
  lib,
  fetchFromGitHub,
  aiocache,
  aiohttp,
  aiounittest,
  buildPythonPackage,
  pytestCheckHook,
  pythonAtLeast,
  setuptools,
}:

buildPythonPackage rec {
  pname = "mypermobil";
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "Permobil-Software";
    repo = "mypermobil";
    tag = "v${version}";
    hash = "sha256-linnaRyA45EzqeSeNmvIE5gXkHA2F504U1++QBeRa90=";
  };

  nativeCheckInputs = [
    aiounittest
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiocache
    aiohttp
  ];

  disabledTests = [
    # requires networking
    "test_region"
  ]
  ++ lib.optionals (pythonAtLeast "3.13") [
    # AssertionError: MyPermobilAPIException not raised
    "test_request_item_404"
  ];

  pyproject = true;
  pythonImportsCheck = [ "mypermobil" ];

  meta = {
    description = "Python wrapper for the MyPermobil API";
    homepage = "https://github.com/Permobil-Software/mypermobil";
    changelog = "https://github.com/Permobil-Software/mypermobil/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
