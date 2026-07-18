{
  lib,
  stdenv,
  fetchFromGitHub,
  aiodns,
  aiohttp,
  audioop-lts,
  brotli,
  buildPythonPackage,
  ffmpeg,
  libopus,
  orjson,
  poetry-core,
  poetry-dynamic-versioning,
  pynacl,
  pythonAtLeast,
  pythonOlder,
  replaceVars,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "nextcord";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "nextcord";
    repo = "nextcord";
    tag = "v${version}";
    hash = "sha256-4/3RM32kEYt5J4bL7/SsPvKhnT1eGS3o0+9lNMqbSj8=";
  };

  patches = [
    (replaceVars ./paths.patch {
      ffmpeg = "${ffmpeg}/bin/ffmpeg";
      libopus = "${libopus}/lib/libopus${stdenv.hostPlatform.extensions.sharedLibrary}";
    })
  ];

  postPatch = ''
    # disable dynamic versioning
    substituteInPlace pyproject.toml \
      --replace-fail 'version = "0.0.0"' 'version = "${version}"' \
      --replace-fail 'enable = true' 'enable = false'
  '';

  # upstream has no tests
  doCheck = false;

  build-system = [
    poetry-core
    poetry-dynamic-versioning
  ];

  dependencies = [
    aiodns
    aiohttp
    brotli
    orjson
    pynacl
    typing-extensions
  ]
  ++ lib.optionals (pythonAtLeast "3.13") [
    audioop-lts
  ];

  disabled = pythonOlder "3.12";
  pyproject = true;

  pythonImportsCheck = [
    "nextcord"
    "nextcord.ext.commands"
    "nextcord.ext.tasks"
  ];

  meta = {
    description = "Python wrapper for the Discord API forked from discord.py";
    homepage = "https://github.com/nextcord/nextcord";
    changelog = "https://github.com/nextcord/nextcord/blob/${src.tag}/docs/whats_new.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
