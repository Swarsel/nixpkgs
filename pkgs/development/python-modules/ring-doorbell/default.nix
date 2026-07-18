{
  lib,
  aiofiles,
  aiohttp,
  aioresponses,
  asyncclick,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  firebase-messaging,
  freezegun,
  hatchling,
  oauthlib,
  pytest-asyncio,
  pytest-freezer,
  pytest-mock,
  pytest-socket,
  pytestCheckHook,
  pytz,
  typing-extensions,
  websockets,
}:

buildPythonPackage (finalAttrs: {
  pname = "ring-doorbell";
  version = "0.9.14";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-M99nwMuo0OziuJpNzuZgK69HtE+/wbOgheij1UwBaRc=";
    pname = "ring_doorbell";
  };

  patches = [
    # https://github.com/python-ring-doorbell/python-ring-doorbell/pull/494
    (fetchpatch {
      excludes = [
        ".github/workflows/ci.yml"
        "uv.lock"
      ];

      hash = "sha256-l6CUg3J6FZ0c0v0SSqvndjl4XeBhGFy/uWHPkExCM50=";
      name = "replace-async-timeout-with-asyncio.timeout.patch";
      url = "https://github.com/python-ring-doorbell/python-ring-doorbell/commit/771243153921ec2cfb5f103b08ed08cccbe2e760.patch";
    })
  ];

  nativeCheckInputs = [
    aioresponses
    freezegun
    pytest-asyncio
    pytest-freezer
    pytest-mock
    pytest-socket
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiofiles
    aiohttp
    asyncclick
    firebase-messaging
    oauthlib
    pytz
    typing-extensions
    websockets
  ];

  pyproject = true;
  pythonImportsCheck = [ "ring_doorbell" ];
  pythonRelaxDeps = [ "requests-oauthlib" ];

  meta = {
    description = "Library to communicate with Ring Door Bell";
    homepage = "https://github.com/tchellomello/python-ring-doorbell";
    changelog = "https://github.com/tchellomello/python-ring-doorbell/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ graham33 ];
    mainProgram = "ring-doorbell";
  };
})
