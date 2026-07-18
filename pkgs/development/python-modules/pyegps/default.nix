{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  pyusb,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pyegps";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "gnumpi";
    repo = "pyegps";
    tag = "v${version}";
    hash = "sha256-iixk2sFa4KAayKFmQKtPjvoIYgxCMXnfkliKhyO2ba4=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ pyusb ];
  pyproject = true;
  pythonImportsCheck = [ "pyegps" ];

  meta = {
    description = "Controlling Energenie Power Strips with python";
    homepage = "https://github.com/gnumpi/pyegps";
    changelog = "https://github.com/gnumpi/pyEGPS/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
