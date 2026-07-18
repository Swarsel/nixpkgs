{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  decorator,
  pbr,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "retry2";
  version = "0.9.5";

  src = fetchFromGitHub {
    owner = "eSAMTrade";
    repo = "retry";
    tag = version;
    hash = "sha256-RxOEekkmMRl2OQW2scFWbMQiFXcH0sbd+k9R8uul0uY=";
  };

  env.PBR_VERSION = version;
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ pbr ];
  dependencies = [ decorator ];
  pyproject = true;
  pythonImportsCheck = [ "retry" ];

  meta = {
    description = "Retry decorator";
    homepage = "https://github.com/eSAMTrade/retry";
    changelog = "https://github.com/eSAMTrade/retry/blob/${src.rev}/ChangeLog";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
