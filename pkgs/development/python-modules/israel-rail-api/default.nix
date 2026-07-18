{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  pytz,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "israel-rail-api";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "sh0oki";
    repo = "israel-rail-api";
    tag = "v${version}";
    hash = "sha256-kcux4IBA3FoNnsqNGHsEta9OAkvjYB40234VlidrNzM=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    pytz
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "israelrailapi" ];

  meta = {
    description = "Python wrapping of the Israeli Rail API";
    homepage = "https://github.com/sh0oki/israel-rail-api";
    changelog = "https://github.com/sh0oki/israel-rail-api/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
