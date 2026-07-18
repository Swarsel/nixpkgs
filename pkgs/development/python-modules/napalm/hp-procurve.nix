{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  napalm,
  netmiko,
  pip,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
  standard-telnetlib,
}:

buildPythonPackage rec {
  pname = "napalm-hp-procurve";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "napalm-automation-community";
    repo = "napalm-hp-procurve";
    tag = version;
    hash = "sha256-cO4kxI90krj1knzixRKWxa77OAaxjO8dLTy02VpkV9M=";
  };

  buildInputs = [ napalm ];

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [
    setuptools
    pip
  ];

  dependencies = [
    netmiko
    standard-telnetlib
  ];

  disabledTests = [
    # AssertionError: Some methods vary.
    "test_method_signatures"
    # AttributeError: 'PatchedProcurveDriver' object has no attribute 'platform'
    "test_get_config_filtered"
    # AssertionError
    "test_get_interfaces"
    "test_get_facts"
  ];

  patchPhase = ''
    # Dependency installation in setup.py doesn't work
    echo -n > requirements.txt
    substituteInPlace setup.cfg \
      --replace " --pylama" ""
  '';

  pyproject = true;
  pythonImportsCheck = [ "napalm_procurve" ];

  meta = {
    description = "HP ProCurve Driver for NAPALM automation frontend";
    homepage = "https://github.com/napalm-automation-community/napalm-hp-procurve";
    changelog = "https://github.com/napalm-automation-community/napalm-hp-procurve/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
