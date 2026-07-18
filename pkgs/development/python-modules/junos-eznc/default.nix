{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jinja2,
  lxml,
  mock,
  ncclient,
  netaddr,
  nose2,
  ntc-templates,
  paramiko,
  pyparsing,
  pyserial,
  pytestCheckHook,
  pyyaml,
  scp,
  setuptools,
  six,
  transitions,
  yamlloader,
}:

buildPythonPackage rec {
  pname = "junos-eznc";
  version = "2.7.6";

  src = fetchFromGitHub {
    owner = "Juniper";
    repo = "py-junos-eznc";
    tag = version;
    hash = "sha256-+bheNSRcFnq/07Y6BaTqsUAVxEQcdQwtz39cX1nKOBs=";
  };

  nativeCheckInputs = [
    mock
    nose2
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    jinja2
    lxml
    ncclient
    netaddr
    ntc-templates
    paramiko
    pyparsing
    pyserial
    pyyaml
    scp
    six
    transitions
    yamlloader
  ];

  disabledTests = [
    # jnpr.junos.exception.FactLoopError: A loop was detected while gathering the...
    "TestPersonality"
    "TestGetSoftwareInformation"
    "TestIfdStyle"
    # KeyError: 'mac'
    "test_textfsm_table_mutli_key"
    # AssertionError: None != 'juniper.net'
    "test_domain_fact_from_config"
  ];

  enabledTestPaths = [ "tests/unit" ];
  pyproject = true;
  pythonImportsCheck = [ "jnpr.junos" ];
  pythonRelaxDeps = [ "ncclient" ];

  meta = {
    description = "Junos 'EZ' automation for non-programmers";
    homepage = "https://github.com/Juniper/py-junos-eznc";
    changelog = "https://github.com/Juniper/py-junos-eznc/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ xnaveira ];
  };
}
