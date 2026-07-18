{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ffmpeg-headless,
  pyee,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "python-ffmpeg";
  version = "2.0.12";

  src = fetchFromGitHub {
    owner = "jonghwanhyeon";
    repo = "python-ffmpeg";
    tag = "v${version}";
    hash = "sha256-1dhkjrg7QUtYSyEV9c88HphdcFuSCSaGJqVAQmMF/5E=";
  };

  postPatch = ''
    substituteInPlace ffmpeg/{ffmpeg.py,asyncio/ffmpeg.py,protocol.py} \
      --replace-fail 'executable: str = "ffmpeg"' 'executable: str = "${lib.getExe ffmpeg-headless}"'
    substituteInPlace tests/helpers.py \
      --replace-fail '"ffprobe"' '"${lib.getExe' ffmpeg-headless "ffprobe"}"'

    # Some systems can finish before the `0.1` timeout.
    substituteInPlace tests/test_{,asyncio_}timeout.py \
      --replace-fail 'ffmpeg.execute(timeout=0.1)' 'ffmpeg.execute(timeout=0.01)'
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  build-system = [ setuptools ];
  dependencies = [ pyee ];
  pyproject = true;
  pythonImportsCheck = [ "ffmpeg" ];

  meta = {
    description = "Python binding for FFmpeg which provides sync and async APIs";
    homepage = "https://github.com/jonghwanhyeon/python-ffmpeg";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ youhaveme9 ];
  };
}
