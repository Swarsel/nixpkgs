{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  async-timeout,
  buildPythonPackage,
  cryptography,
  hatchling,
  http-ece,
  myst-parser,
  protobuf,
  pytest-asyncio,
  pytest-mock,
  pytest-socket,
  pytestCheckHook,
  requests-mock,
  sphinx,
  sphinx-autodoc-typehints,
  sphinx-rtd-theme,
  sphinxHook,
}:

buildPythonPackage rec {
  pname = "firebase-messaging";
  version = "0.4.5";

  src = fetchFromGitHub {
    owner = "sdb9696";
    repo = "firebase-messaging";
    tag = version;
    hash = "sha256-O1A+hGEhnNcvdXw5QJx+3zYKB+m36N0Ge0XB6cZ6930=";
  };

  outputs = [
    "out"
    "doc"
  ];

  nativeBuildInputs = [
    sphinxHook
  ]
  ++ optional-dependencies.docs;

  nativeCheckInputs = [
    aioresponses
    async-timeout
    requests-mock
    pytest-asyncio
    pytest-mock
    pytest-socket
    pytestCheckHook
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    aiohttp
    cryptography
    http-ece
    protobuf
  ];

  optional-dependencies = {
    docs = [
      myst-parser
      sphinx
      sphinx-autodoc-typehints
      sphinx-rtd-theme
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "firebase_messaging" ];

  pythonRelaxDeps = [
    "http-ece"
    "protobuf"
  ];

  meta = {
    description = "Library to subscribe to GCM/FCM and receive notifications within a python application";
    homepage = "https://github.com/sdb9696/firebase-messaging";
    changelog = "https://github.com/sdb9696/firebase-messaging/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
