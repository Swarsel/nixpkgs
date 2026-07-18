{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cffi,
  ddt,
  fetchpatch,
  # dependencies
  jinja2,
  junos-eznc,
  lxml,
  mock,
  ncclient,
  netaddr,
  netmiko,
  netutils,
  paramiko,
  pyeapi,
  # tests
  pytestCheckHook,
  pyyaml,
  requests,
  scp,
  # build-system
  setuptools,
  textfsm,
  ttp,
  ttp-templates,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "napalm";
  version = "5.1.0";

  src = fetchFromGitHub {
    owner = "napalm-automation";
    repo = "napalm";
    tag = finalAttrs.version;
    hash = "sha256-kIQgr5W9xkdcQkscJkOiABJ5HBxZOT9D7jSKWGNoBGA=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    mock
    ddt
  ];

  build-system = [ setuptools ];

  dependencies = [
    cffi
    jinja2
    junos-eznc
    lxml
    ncclient
    netaddr
    netmiko
    # breaks infinite recursion
    (netutils.override { napalm = null; })
    paramiko
    pyeapi
    pyyaml
    requests
    scp
    setuptools
    textfsm
    ttp
    ttp-templates
    typing-extensions
  ];

  pyproject = true;

  meta = {
    description = "Network Automation and Programmability Abstraction Layer with Multivendor support";
    homepage = "https://github.com/napalm-automation/napalm";
    license = lib.licenses.asl20;
  };
})
