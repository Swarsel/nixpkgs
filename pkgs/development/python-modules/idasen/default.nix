{
  lib,
  fetchFromGitHub,
  bleak,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  pyyaml,
  setuptools,
  voluptuous,
}:

buildPythonPackage (finalAttrs: {
  pname = "idasen";
  version = "0.13.1";

  src = fetchFromGitHub {
    owner = "newAM";
    repo = "idasen";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ejKfXAVvHyWIkg06XqC2pKJjpPuOgHEciPzBb/TGiSU=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  build-system = [ setuptools ];

  dependencies = [
    bleak
    pyyaml
    voluptuous
  ];

  pyproject = true;
  pythonImportsCheck = [ "idasen" ];

  meta = {
    description = "Python API and CLI for the ikea IDÅSEN desk";
    homepage = "https://github.com/newAM/idasen";
    changelog = "https://github.com/newAM/idasen/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ newam ];
    mainProgram = "idasen";
  };
})
