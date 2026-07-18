{
  lib,
  fetchFromGitHub,
  aiosendspin,
  aiosendspin-mpris,
  av,
  buildPythonPackage,
  numpy,
  pulsectl-asyncio,
  pychromecast,
  pyprojectVersionPatchHook,
  pytest-asyncio,
  pytestCheckHook,
  qrcode,
  readchar,
  rich,
  setuptools,
  sounddevice,
}:

buildPythonPackage (finalAttrs: {
  pname = "sendspin";
  version = "7.4.0";

  src = fetchFromGitHub {
    owner = "Sendspin";
    repo = "sendspin-cli";
    tag = finalAttrs.version;
    hash = "sha256-B375jsOik0IdLtozH3t3hZKqoO+dtqkzX2bk5YuoO9Y=";
  };

  nativeBuildInputs = [
    pyprojectVersionPatchHook
  ];

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiosendspin
    aiosendspin-mpris
    av
    numpy
    pulsectl-asyncio
    qrcode
    readchar
    rich
    sounddevice
  ]
  ++ aiosendspin.optional-dependencies.server;

  disabledTests = [
    # requires internet
    "test_multi_worker_starts_and_serves_status"
  ];

  optional-dependencies = {
    cast = [ pychromecast ];
  };

  pyproject = true;
  pythonImportsCheck = [ "sendspin" ];

  meta = {
    description = "Synchronized audio player for Sendspin servers";
    homepage = "https://github.com/Sendspin/sendspin-cli";
    changelog = "https://github.com/Sendspin/sendspin-cli/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
