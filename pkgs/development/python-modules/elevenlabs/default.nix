{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  poetry-core,
  pyaudio,
  pydantic,
  pydantic-core,
  requests,
  typing-extensions,
  websockets,
}:

buildPythonPackage (finalAttrs: {
  pname = "elevenlabs";
  version = "2.56.0";

  src = fetchFromGitHub {
    owner = "elevenlabs";
    repo = "elevenlabs-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Ps4W8uSv2eH5DSJpDBmaitrv+AegA+UJKjiiAfK5gOQ=";
  };

  # tests access the API on the internet
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    httpx
    pydantic
    pydantic-core
    requests
    typing-extensions
    websockets
  ];

  optional-dependencies = {
    pyaudio = [ pyaudio ];
  };

  pyproject = true;
  pythonImportsCheck = [ "elevenlabs" ];

  meta = {
    description = "Official Python API for ElevenLabs Text to Speech";
    homepage = "https://github.com/elevenlabs/elevenlabs-python";
    changelog = "https://github.com/elevenlabs/elevenlabs-python/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
