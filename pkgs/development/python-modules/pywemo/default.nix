{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  hypothesis,
  ifaddr,
  lxml,
  poetry-core,
  pytest-vcr,
  pytestCheckHook,
  requests,
  urllib3,
}:

buildPythonPackage (finalAttrs: {
  pname = "pywemo";
  version = "2.1.2";

  src = fetchFromGitHub {
    owner = "pywemo";
    repo = "pywemo";
    tag = finalAttrs.version;
    hash = "sha256-/F9MhPmWSLT/ieI21rzJXvjEkH8xBttJYPaQ1wcVWOk=";
  };

  nativeCheckInputs = [
    hypothesis
    pytest-vcr
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ poetry-core ];

  dependencies = [
    cryptography
    ifaddr
    lxml
    requests
    urllib3
  ];

  pyproject = true;
  pythonImportsCheck = [ "pywemo" ];

  meta = {
    description = "Python module to discover and control WeMo devices";
    homepage = "https://github.com/pywemo/pywemo";
    changelog = "https://github.com/pywemo/pywemo/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
