{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jinja2,
  jsonschema,
  napalm,
  poetry-core,
  pytestCheckHook,
  pyyaml,
  toml,
}:

buildPythonPackage (finalAttrs: {
  pname = "netutils";
  version = "1.17.2";

  src = fetchFromGitHub {
    owner = "networktocode";
    repo = "netutils";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DHftRRqbuUa74ATfh8MHxINwNkpz9lo/drwOmeo0itE=";
  };

  nativeCheckInputs = [
    jinja2
    pytestCheckHook
    pyyaml
    toml
  ];

  build-system = [ poetry-core ];
  dependencies = [ jsonschema ];

  disabledTests = [
    # Tests require network access
    "test_is_fqdn_resolvable"
    "test_fqdn_to_ip"
    "test_tcp_ping"
    # Skip Sphinx test
    "test_sphinx_build"
    # OSError: [Errno 22] Invalid argument
    "test_compare_type5"
    "test_encrypt_type5"
    "test_compare_cisco_type5"
    "test_get_napalm_getters_napalm_installed_default"
    "test_encrypt_cisco_type5"
  ];

  optional-dependencies.optionals = [
    jsonschema
    napalm
  ];

  pyproject = true;
  pythonImportsCheck = [ "netutils" ];

  meta = {
    description = "Library that is a collection of objects for common network automation tasks";
    homepage = "https://github.com/networktocode/netutils";
    changelog = "https://github.com/networktocode/netutils/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
