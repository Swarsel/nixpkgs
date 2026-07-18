{
  lib,
  fetchFromGitHub,
  bleak,
  bleak-retry-connector,
  buildPythonPackage,
  cryptography,
  epaper-dithering,
  hatchling,
  numpy,
  pillow,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "py-opendisplay";
  version = "7.2.3";

  src = fetchFromGitHub {
    owner = "OpenDisplay";
    repo = "py-opendisplay";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ByLbrsIbyCHNvzJuMy7kat6gWoU8Bb42adH03CH+G+g=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  build-system = [ hatchling ];

  dependencies = [
    bleak
    bleak-retry-connector
    cryptography
    epaper-dithering
    numpy
    pillow
  ];

  pyproject = true;
  pythonImportsCheck = [ "opendisplay" ];
  pythonRelaxDeps = [ "epaper-dithering" ];

  meta = {
    description = "Python library for communicating with OpenDisplay BLE e-paper displays";
    homepage = "https://github.com/OpenDisplay/py-opendisplay";
    changelog = "https://github.com/OpenDisplay/py-opendisplay/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
