{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  lxml,
  pytestCheckHook,
  requests,
}:

buildPythonPackage (finalAttrs: {
  pname = "py-netgear-plus";
  version = "0.6.4";

  src = fetchFromGitHub {
    owner = "foxey";
    repo = "py-netgear-plus";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UDy5kMfSrKXLsGTRLcYWqi7Mv1dtYSaIx+sy8PHipKE=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    lxml
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "py_netgear_plus" ];

  meta = {
    description = "Python Library for NETGEAR Plus Switches";
    homepage = "https://github.com/foxey/py-netgear-plus";
    changelog = "https://github.com/foxey/py-netgear-plus/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ aiyion ];
  };
})
