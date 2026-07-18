{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  requests,
  responses,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "gocardless-pro";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "gocardless";
    repo = "gocardless-pro-python";
    tag = "v${version}";
    hash = "sha256-XD5GUiSHTq/DLrKo6FY4moNnbFpXkVJWM13Yu6c+tZw=";
  };

  propagatedBuildInputs = [
    requests
    six
  ];

  nativeCheckInputs = [
    pytestCheckHook
    responses
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "gocardless_pro" ];

  meta = {
    description = "Client library for the GoCardless Pro API";
    homepage = "https://github.com/gocardless/gocardless-pro-python";
    changelog = "https://github.com/gocardless/gocardless-pro-python/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
