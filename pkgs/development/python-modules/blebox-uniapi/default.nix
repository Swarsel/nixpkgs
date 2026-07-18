{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  deepmerge,
  jmespath,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "blebox-uniapi";
  version = "2.5.5";

  src = fetchFromGitHub {
    owner = "blebox";
    repo = "blebox_uniapi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vmVCXzfs/LYn2lT3lqdRy4cJcieF1idljH5IPKeH4QA=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "pytest-runner" ""
  '';

  nativeCheckInputs = [
    deepmerge
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    jmespath
  ];

  pyproject = true;
  pythonImportsCheck = [ "blebox_uniapi" ];

  meta = {
    description = "Python API for accessing BleBox smart home devices";
    homepage = "https://github.com/blebox/blebox_uniapi";
    changelog = "https://github.com/blebox/blebox_uniapi/blob/${finalAttrs.src.tag}/HISTORY.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
