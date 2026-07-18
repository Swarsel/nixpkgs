{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
}:

let
  pname = "ephemeral-port-reserve";
  version = "1.1.4";
in
buildPythonPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "Yelp";
    repo = "ephemeral-port-reserve";
    rev = "v${version}";
    hash = "sha256-R6NRpfaT05PO/cTWgCakiGfCuCyucjVOXbAezn5x1cU=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __darwinAllowLocalNetworking = true;

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # can't find hostname in our darwin build environment
    "test_fqdn"
  ];

  format = "setuptools";
  pythonImportsCheck = [ "ephemeral_port_reserve" ];

  meta = {
    description = "Find an unused port, reliably";
    homepage = "https://github.com/Yelp/ephemeral-port-reserve/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
    mainProgram = "ephemeral-port-reserve";
  };
}
