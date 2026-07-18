{
  lib,
  stdenv,
  fetchFromGitHub,
  aiohttp,
  aiomqtt,
  aioresponses,
  buildPythonPackage,
  click,
  click-shell,
  construct,
  freezegun,
  hatchling,
  paho-mqtt,
  protobuf,
  pycryptodome,
  pycryptodomex,
  pyrate-limiter,
  pyshark,
  pytest-asyncio,
  pytestCheckHook,
  pyyaml,
  syrupy,
  vacuum-map-parser-roborock,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-roborock";
  version = "5.25.0";

  src = fetchFromGitHub {
    owner = "Python-roborock";
    repo = "python-roborock";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Uj7rr9vAdZBseeePQU1/3bILwsI0P2CDy1bGu6R90Cg=";
  };

  nativeCheckInputs = [
    aioresponses
    freezegun
    pytest-asyncio
    pytestCheckHook
    syrupy
    writableTmpDirAsHomeHook
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  __darwinAllowLocalNetworking = true;
  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    aiomqtt
    construct
    paho-mqtt
    protobuf
    pycryptodome
    pyrate-limiter
    vacuum-map-parser-roborock
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ pycryptodomex ];

  optional-dependencies.cli = [
    click
    click-shell
    pyyaml
    pyshark
  ];

  pyproject = true;
  pythonImportsCheck = [ "roborock" ];

  pythonRelaxDeps = [
    "protobuf"
    "pycryptodome"
  ];

  meta = {
    description = "Python library & console tool for controlling Roborock vacuum";
    homepage = "https://github.com/Python-roborock/python-roborock";
    changelog = "https://github.com/Python-roborock/python-roborock/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "roborock";
  };
})
