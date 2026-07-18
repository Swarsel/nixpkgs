{
  lib,
  fetchFromGitHub,
  audioop-lts,
  buildPythonPackage,
  fetchpatch,
  ffmpeg,
  pytestCheckHook,
  replaceVars,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pydub";
  version = "0.25.1";

  src = fetchFromGitHub {
    owner = "jiaaro";
    repo = "pydub";
    tag = "v${version}";
    hash = "sha256-FTEMT47wPXK5i4ZGjTVAhI/NjJio3F2dbBZzYzClU3c=";
  };

  patches = [
    # Fix test assertions, https://github.com/jiaaro/pydub/pull/769
    (fetchpatch {
      hash = "sha256-3OIzvTgGK3r4/s5y7izHvouB4uJEmjO6cgKvegtTf7A=";
      name = "fix-assertions.patch";
      url = "https://github.com/jiaaro/pydub/commit/66c1bf7813ae8621a71484fdcdf609734c0d8efd.patch";
    })
    # Fix paths to ffmpeg, ffplay and ffprobe
    (replaceVars ./ffmpeg-fix-path.patch {
      ffmpeg = lib.getExe ffmpeg;
      ffplay = lib.getExe' ffmpeg "ffplay";
      ffprobe = lib.getExe' ffmpeg "ffprobe";
    })
  ];

  nativeBuildInputs = [ setuptools ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  dependencies = [ audioop-lts ];
  enabledTestPaths = [ "test/test.py" ];
  pyproject = true;

  pythonImportsCheck = [
    "pydub"
    "pydub.audio_segment"
    "pydub.playback"
  ];

  meta = {
    description = "Manipulate audio with a simple and easy high level interface";
    homepage = "http://pydub.com";
    changelog = "https://github.com/jiaaro/pydub/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
