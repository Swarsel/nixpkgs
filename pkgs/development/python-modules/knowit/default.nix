{
  lib,
  fetchFromGitHub,
  # dependencies
  babelfish,
  buildPythonPackage,
  enzyme,
  fetchzip,
  ffmpeg,
  mediainfo,
  mkvtoolnix,
  pint,
  # build-system
  poetry-core,
  pymediainfo,
  # nativeCheckInputs
  pytestCheckHook,
  pyyaml,
  requests,
  trakit,
}:

buildPythonPackage rec {
  pname = "knowit";
  version = "0.5.11";

  src = fetchFromGitHub {
    owner = "ratoaq2";
    repo = "knowit";
    tag = version;
    hash = "sha256-JqzCLdXEWZyvqXpeTJRW0zhY+wVcHLuBYrJbuSqfgkg=";
  };

  postPatch = ''
    mkdir -p tests/data/videos
    cp ${matroska_test_zip}/*.mkv tests/data/videos/
  '';

  nativeCheckInputs = [
    pytestCheckHook
    ffmpeg
    mediainfo
    mkvtoolnix
    requests
  ];

  build-system = [
    poetry-core
  ];

  dependencies = [
    babelfish
    enzyme
    pymediainfo
    pyyaml
    trakit
  ];

  matroska_test_zip = fetchzip {
    hash = "sha256-X8gIfDj2iP043kjO3yqxuIgn8mZMX7XaqzhQ7CTLUhc=";
    stripRoot = false;
    url = "http://downloads.sourceforge.net/project/matroska/test_files/matroska_test_w1_1.zip";
  };

  optional-dependencies = {
    pint = [
      pint
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "knowit"
  ];

  meta = {
    description = "Extract metadata from media files";
    homepage = "https://github.com/ratoaq2/knowit";
    changelog = "https://github.com/ratoaq2/knowit/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ iynaix ];
    mainProgram = "knowit";
  };
}
