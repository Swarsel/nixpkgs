{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytest-mock,
  pytestCheckHook,
  requests,
  retry2,
}:

buildPythonPackage (finalAttrs: {
  pname = "zeversolar";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "kvanzuijlen";
    repo = "zeversolar";
    tag = finalAttrs.version;
    hash = "sha256-6hAvZL4PbtuFnDXRrVeYuylR9SIZ9B46CA0Ms/w4Y24=";
  };

  nativeCheckInputs = [
    pytest-mock
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    requests
    retry2
  ];

  pyproject = true;
  pythonImportsCheck = [ "zeversolar" ];

  meta = {
    description = "Module to interact with the local CGI provided by ZeverSolar";
    homepage = "https://github.com/kvanzuijlen/zeversolar";
    changelog = "https://github.com/kvanzuijlen/zeversolar/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
