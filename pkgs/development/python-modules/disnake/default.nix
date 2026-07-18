{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  ffmpeg,
  libopus,
  looptime,
  pynacl,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  typing-extensions,
  withVoice ? true,
}:

buildPythonPackage rec {
  pname = "disnake";
  version = "2.11.0";

  src = fetchFromGitHub {
    owner = "DisnakeDev";
    repo = "disnake";
    tag = "v${version}";
    hash = "sha256-pwhUX5lzqSPik/rPsT42M3AMjzWWeqFN+0mVHA84cCo=";
  };

  postPatch = lib.optionalString withVoice ''
    substituteInPlace "disnake/opus.py" \
      --replace-fail 'ctypes.util.find_library("opus")' "'${libopus}/lib/libopus.so.0'"
    substituteInPlace "disnake/player.py" \
      --replace-fail 'executable: str = "ffmpeg"' 'executable: str="${ffmpeg}/bin/ffmpeg"'
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    looptime
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    typing-extensions
  ]
  ++ lib.optionals withVoice [
    libopus
    pynacl
    ffmpeg
  ];

  pyproject = true;

  pytestFlags = [
    # DeprecationWarning: There is no current event loop
    "-Wignore::DeprecationWarning"
  ];

  pythonImportsCheck = [
    "disnake"
    "disnake.file"
    "disnake.member"
    "disnake.user"
    "disnake.state"
    "disnake.guild"
    "disnake.webhook"
    "disnake.ext.commands.bot"
  ];

  meta = {
    description = "API wrapper for Discord written in Python";
    homepage = "https://disnake.dev/";
    changelog = "https://github.com/DisnakeDev/disnake/blob/${src.tag}/docs/whats_new.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ infinidoge ];
  };
}
