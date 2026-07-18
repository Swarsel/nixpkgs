{
  lib,
  buildPythonPackage,
  cacert,
  fetchPypi,
  hatchling,
  portpicker,
  pytest,
  pytestCheckHook,
  scim2-client,
  scim2-server,
}:

buildPythonPackage rec {
  pname = "pytest-scim2-server";
  version = "0.1.6";

  # Pypi doesn't link a VCS repository
  src = fetchPypi {
    inherit version;
    hash = "sha256-Diu8TPPELQG30NZvafI/t7IR+HzkI0sPsjcUFxwVPLw=";
    pname = "pytest_scim2_server";
  };

  env.SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  nativeCheckInputs = [
    pytestCheckHook
    scim2-client
  ]
  ++ scim2-client.optional-dependencies.httpx;

  build-system = [ hatchling ];

  dependencies = [
    portpicker
    pytest
    scim2-server
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytest_scim2_server" ];

  meta = {
    homepage = "https://pypi.org/project/pytest-scim2-server";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ erictapen ];
  };
}
