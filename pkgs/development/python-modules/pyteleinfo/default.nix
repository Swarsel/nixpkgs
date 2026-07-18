{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pydantic-settings,
  pyhamcrest,
  pyserial,
  pyserial-asyncio-fast,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-mock,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyteleinfo";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "esciara";
    repo = "pyteleinfo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uNkCunWlFoGmg80t69z2PXyPL1pGDsezTc8heec97VI=";
  };

  nativeCheckInputs = [
    pyhamcrest
    pytest-asyncio
    pytest-cov-stub
    pytest-mock
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    pydantic-settings
    pyserial
    pyserial-asyncio-fast
  ];

  pyproject = true;
  pythonImportsCheck = [ "teleinfo" ];
  pythonRelaxDeps = [ "pydantic-settings" ];

  meta = {
    description = "Python library for decoding and encoding ENEDIS teleinfo frames";
    homepage = "https://github.com/esciara/pyteleinfo";
    changelog = "https://github.com/esciara/pyteleinfo/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
