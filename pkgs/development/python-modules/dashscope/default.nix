{
  # Basic
  lib,
  fetchFromGitHub,
  # Dependencies
  aiohttp,
  buildPythonPackage,
  certifi,
  cryptography,
  # Test
  pytestCheckHook,
  requests,
  # Build system
  setuptools,
  tiktoken,
  websocket-client,
}:

buildPythonPackage rec {
  pname = "dashscope";
  version = "1.25.9";

  src = fetchFromGitHub {
    owner = "dashscope";
    repo = "dashscope-sdk-python";
    tag = "v${version}";
    hash = "sha256-VR7Auso+0al9qAE3IDFAPl5zIX0Yp9OfJchR+Q9DB1o=";
  };

  # Specify the version explicitly
  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "version=get_version()," "version='${version}',"
  '';

  nativeCheckInputs = [
    pytestCheckHook
    tiktoken
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    requests
    websocket-client
    cryptography
    certifi
  ];

  disabledTests = [
    # Needs network access and/or API key
    "TestAsyncImageSynthesisRequest"
    "TestAsyncRequest"
    "TestAsyncVideoSynthesisRequest"
    "TestEncryption"
    "TestSpeechRecognition"
    "TestSpeechTranscribe"
    "TestSynthesis"
    "TestWebSocketAsyncRequest"
    "TestWebSocketSyncRequest"
  ];

  pyproject = true;
  pythonImportsCheck = [ "dashscope" ];

  meta = {
    description = "Python SDK for dashscope";
    homepage = "https://github.com/dashscope/dashscope-sdk-python";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ thattemperature ];
  };
}
