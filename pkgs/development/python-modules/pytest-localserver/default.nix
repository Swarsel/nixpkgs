{
  lib,
  aiosmtpd,
  buildPythonPackage,
  fetchPypi,
  setuptools-scm,
  werkzeug,
}:

buildPythonPackage (finalAttrs: {
  pname = "pytest-localserver";
  version = "0.10.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-JgcZfzkJEqslUl0SmsQ8PIdQSSVzaLP+CbXNA9zFJq8=";
    pname = "pytest_localserver";
  };

  # All tests access network: does not work in sandbox
  doCheck = false;
  build-system = [ setuptools-scm ];
  dependencies = [ werkzeug ];

  optional-dependencies = {
    smtp = [ aiosmtpd ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pytest_localserver" ];

  meta = {
    description = "Plugin for the pytest testing framework to test server connections locally";
    homepage = "https://github.com/pytest-dev/pytest-localserver";
    changelog = "https://github.com/pytest-dev/pytest-localserver/blob/v${finalAttrs.version}/CHANGES";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ siriobalmelli ];
  };
})
