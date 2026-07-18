{
  lib,
  stdenv,
  fetchFromGitHub,
  # dependencies
  aiohttp,
  # tests
  aioresponses,
  bellows,
  buildPythonPackage,
  coloredlogs,
  crc,
  gpiod,
  pytest-asyncio,
  pytestCheckHook,
  # build-system
  setuptools,
  tqdm,
  typing-extensions,
  zigpy,
}:

buildPythonPackage rec {
  pname = "universal-silabs-flasher";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "NabuCasa";
    repo = "universal-silabs-flasher";
    tag = "v${version}";
    hash = "sha256-niNjHhOwy+5mgs4UY9bIBykmZ+7TifbYnMuG1LAV7PA=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"setuptools-git-versioning>=2.0,<3"' "" \
      --replace-fail 'dynamic = ["version"]' 'version = "${version}"'
  '';

  nativeCheckInputs = [
    aioresponses
    pytestCheckHook
    pytest-asyncio
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    bellows
    coloredlogs
    crc
    tqdm
    typing-extensions
    zigpy
  ]
  ++ lib.optionals (stdenv.hostPlatform.isLinux) [ gpiod ];

  disabledTests = [
    # timing sensitive
    "test_xmodem_happy_path"
  ];

  pyproject = true;
  pythonImportsCheck = [ "universal_silabs_flasher" ];

  meta = {
    description = "Flashes Silicon Labs radios running EmberZNet or CPC multi-pan firmware";
    homepage = "https://github.com/NabuCasa/universal-silabs-flasher";
    changelog = "https://github.com/NabuCasa/universal-silabs-flasher/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ hexa ];
    mainProgram = "universal-silabs-flasher";
  };
}
