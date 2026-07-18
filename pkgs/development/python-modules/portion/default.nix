{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatchling,
  # tests
  pytest-benchmark,
  pytestCheckHook,
  # dependencies
  sortedcontainers,
}:

buildPythonPackage (finalAttrs: {
  pname = "portion";
  version = "2.6.2";

  src = fetchFromGitHub {
    owner = "AlexandreDecan";
    repo = "portion";
    tag = finalAttrs.version;
    hash = "sha256-ns9kUoSufegx0I3ag/KVl68ZviEIRx+zPA+BSWq3k80=";
  };

  nativeCheckInputs = [
    pytest-benchmark
    pytestCheckHook
  ];

  __structuredAttrs = true;
  build-system = [ hatchling ];
  dependencies = [ sortedcontainers ];
  pyproject = true;
  pythonImportsCheck = [ "portion" ];

  meta = {
    description = "Python library providing data structure and operations for intervals";
    homepage = "https://github.com/AlexandreDecan/portion";
    changelog = "https://github.com/AlexandreDecan/portion/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
