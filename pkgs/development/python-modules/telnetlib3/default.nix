{
  lib,
  fetchFromGitHub,
  addBinToPathHook,
  blessed,
  buildPythonPackage,
  hatchling,
  pexpect,
  prettytable,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-timeout,
  pytest-xdist,
  pytestCheckHook,
  trustme,
  wcwidth,
}:

buildPythonPackage (finalAttrs: {
  pname = "telnetlib3";
  version = "4.0.5";

  src = fetchFromGitHub {
    owner = "jquast";
    repo = "telnetlib3";
    tag = finalAttrs.version;
    hash = "sha256-qJ9fbly8nNCOppLxEnzmKTE0CbbORnkANvbioSZUgmk=";
  };

  nativeCheckInputs = [
    addBinToPathHook
    pexpect
    pytest-asyncio
    pytest-cov-stub
    pytest-timeout
    pytest-xdist
    pytestCheckHook
    trustme
  ];

  build-system = [ hatchling ];

  dependencies = [
    blessed
    wcwidth
  ];

  optional-dependencies = {
    extras = [
      prettytable
      # FIXME package ucs-detect
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "telnetlib3" ];

  pythonRelaxDeps = [
    "wcwidth"
  ];

  meta = {
    description = "Feature-rich Telnet Server, Client, and Protocol library for Python";
    homepage = "https://github.com/jquast/telnetlib3";
    changelog = "https://github.com/jquast/telnetlib3/blob/${finalAttrs.src.tag}/docs/history.rst";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.dotlambda ];
  };
})
