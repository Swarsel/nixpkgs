{
  lib,
  fetchFromGitHub,
  aiofiles,
  aiohttp,
  buildPythonPackage,
  dataclass-factory,
  fetchpatch,
  ffmpeg,
  numpy,
  poetry-core,
  pydantic,
  pydub,
  pytest-asyncio,
  pytestCheckHook,
  wheel,
}:

buildPythonPackage rec {
  pname = "shazamio";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "dotX12";
    repo = "ShazamIO";
    tag = version;
    hash = "sha256-beEEr9Y8w0XlC/0+mNL/oWscmnfwt9KChlZ7Ullyk3E=";
  };

  patches = [
    # remove poetry and virtualenv from build dependencies as they are not used
    # https://github.com/dotX12/ShazamIO/pull/71
    (fetchpatch {
      hash = "sha256-KiU5RVBPnSs5qrReFeTe9ePg1fR7y0NchIIHcQwlPaI=";
      name = "remove-unused-build-dependencies.patch";
      url = "https://github.com/dotX12/ShazamIO/commit/5c61e1efe51c2826852da5b6aa6ad8ce3d4012a9.patch";
    })
  ];

  nativeBuildInputs = [
    poetry-core
    wheel
  ];

  propagatedBuildInputs = [
    aiofiles
    aiohttp
    dataclass-factory
    numpy
    pydantic
    pydub
  ];

  nativeCheckInputs = [
    ffmpeg
    pytest-asyncio
    pytestCheckHook
  ];

  disabledTests = [
    # requires internet access
    "test_about_artist"
    "test_recognize_song_file"
    "test_recognize_song_bytes"
  ];

  pyproject = true;
  pythonImportsCheck = [ "shazamio" ];

  meta = {
    description = "Free asynchronous library from reverse engineered Shazam API";
    homepage = "https://github.com/dotX12/ShazamIO";
    changelog = "https://github.com/dotX12/ShazamIO/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
    # https://github.com/shazamio/ShazamIO/issues/80
    broken = lib.versionAtLeast pydantic.version "2";
  };
}
