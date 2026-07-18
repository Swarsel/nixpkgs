{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  lifx-emulator-core,
  pytest-asyncio,
  pytest-benchmark,
  pytest-cov-stub,
  pytest-retry,
  pytest-timeout,
  pytest-xdist,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "lifx-async";
  version = "5.4.9";

  src = fetchFromGitHub {
    owner = "Djelibeybi";
    repo = "lifx-async";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DWclqWrCoUfFC2gu1CbrqHxx4BFP1jV597c4llq2B5A=";
  };

  nativeCheckInputs = [
    lifx-emulator-core
    pytest-asyncio
    pytest-benchmark
    pytest-cov-stub
    pytest-retry
    pytest-timeout
    pytest-xdist
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "lifx" ];

  meta = {
    description = "Modern, type-safe, async Python library for controlling LIFX lights";
    homepage = "https://github.com/Djelibeybi/lifx-async/";
    license = lib.licenses.upl;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
})
