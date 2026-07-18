{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fake-http-header,
  idna,
  mockito,
  playwright,
  poetry-core,
  pytestCheckHook,
  urllib3,
}:

buildPythonPackage (finalAttrs: {
  pname = "tf-playwright-stealth";
  version = "1.2.2-unstable-2026-06-30";

  src = fetchFromGitHub {
    owner = "tinyfish-io";
    repo = "tf-playwright-stealth";
    rev = "01b1b7a436edee4363a5d6f78f626a602550138b";
    hash = "sha256-dUU0JqnEda0s6nVzJNmU1l536YZ05SI3DYhb7onuBwY=";
  };

  nativeCheckInputs = [
    mockito
    pytestCheckHook
  ];

  __structuredAttrs = true;
  build-system = [ poetry-core ];

  dependencies = [
    fake-http-header
    idna
    playwright
    urllib3
  ];

  disabledTestPaths = [
    # Requires agentql
    "tests/e2e/"
  ];

  pyproject = true;
  pythonImportsCheck = [ "playwright_stealth" ];

  pythonRelaxDeps = [
    "idna"
    "urllib3"
  ];

  pythonRemoveDeps = [ "agentql" ];

  meta = with lib; {
    description = "Module for using playwright stealthy";
    homepage = "https://github.com/tinyfish-io/tf-playwright-stealth";
    license = licenses.mit;
    maintainers = with maintainers; [ fab ];
  };
})
