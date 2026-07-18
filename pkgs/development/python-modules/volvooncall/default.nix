{
  lib,
  fetchFromGitHub,
  aiohttp,
  amqtt,
  buildPythonPackage,
  certifi,
  docopt,
  fetchpatch,
  geopy,
  mock,
  pytest-asyncio_0,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "volvooncall";
  version = "0.10.4";

  src = fetchFromGitHub {
    owner = "molobrakos";
    repo = "volvooncall";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xr3g93rt3jvxVZrZY7cFh5eBP3k0arsejsgvx8p5EV4=";
  };

  patches = [
    # Remove asynctest, https://github.com/molobrakos/volvooncall/pull/92
    (fetchpatch {
      hash = "sha256-U+hM7vzD9JSEUumvjPSLpVQcc8jAuZHG3/1dQ3wnIcA=";
      name = "remove-asnyc.patch";
      url = "https://github.com/molobrakos/volvooncall/commit/ef0df403250288c00ed4c600e9dfa79dcba8941e.patch";
    })
  ];

  checkInputs = [
    mock
    pytest-asyncio_0
    pytestCheckHook
  ]
  ++ finalAttrs.passthru.optional-dependencies.mqtt;

  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];

  optional-dependencies = {
    console = [
      certifi
      docopt
      geopy
    ];

    mqtt = [
      amqtt
      certifi
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "volvooncall" ];

  meta = {
    description = "Retrieve information from the Volvo On Call web service";
    homepage = "https://github.com/molobrakos/volvooncall";
    changelog = "https://github.com/molobrakos/volvooncall/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "voc";
  };
})
