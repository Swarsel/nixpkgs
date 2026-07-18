{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  requests,
  responses,
  setuptools,
}:
buildPythonPackage (finalAttrs: {
  pname = "btsmarthub-devicelist";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "jxwolstenholme";
    repo = "btsmarthub_devicelist";
    tag = finalAttrs.version;
    hash = "sha256-7ncxCpY+A2SuSFa3k21QchrmFs1dPRUMb1r1z/laa6M=";
  };

  nativeCheckInputs = [
    responses
    requests
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ requests ];
  disabledTests = [ "test_btsmarthub2_detection_neither_router_present" ];
  pyproject = true;

  meta = {
    description = "Retrieve a list of devices from a bt smarthub or bt smarthub 2 on a local network";
    homepage = "https://github.com/jxwolstenholme/btsmarthub_devicelist";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jamiemagee ];
  };
})
