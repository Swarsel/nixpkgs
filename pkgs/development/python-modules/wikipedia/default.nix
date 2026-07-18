{
  lib,
  beautifulsoup4,
  buildPythonPackage,
  fetchPypi,
  requests,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "wikipedia";
  version = "1.4.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-2w+tGCn91EGxhSMG6YVjmCBNwHhtKZbdLgyLuOJhM7I=";
  };

  nativeCheckInputs = [ unittestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    beautifulsoup4
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "wikipedia" ];
  unittestFlagsArray = [ "tests/ '*test.py'" ];

  meta = {
    description = "Pythonic wrapper for the Wikipedia API";
    homepage = "https://github.com/goldsmith/Wikipedia";
    changelog = "https://github.com/goldsmith/Wikipedia/blob/master/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ natsukium ];
  };
})
