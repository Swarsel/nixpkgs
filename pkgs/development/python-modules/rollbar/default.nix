{
  lib,
  aiocontextvars,
  blinker,
  buildPythonPackage,
  fetchPypi,
  httpx,
  mock,
  pytestCheckHook,
  requests,
  setuptools,
  six,
  webob,
}:

buildPythonPackage rec {
  pname = "rollbar";
  version = "1.3.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-UZQC6sObzE+khIIYcva7GEl/t7bIEWcEeGfRdxTTs3k=";
  };

  # Still supporting unittest2
  # https://github.com/rollbar/pyrollbar/pull/346
  # https://github.com/rollbar/pyrollbar/pull/340
  doCheck = false;

  nativeCheckInputs = [
    webob
    blinker
    mock
    httpx
    aiocontextvars
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    requests
    six
  ];

  pyproject = true;
  pythonImportsCheck = [ "rollbar" ];

  meta = {
    description = "Error tracking and logging from Python to Rollbar";
    homepage = "https://github.com/rollbar/pyrollbar";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "rollbar";
  };
}
