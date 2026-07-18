{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ffmpeg,
  # checks
  psutil,
  pytestCheckHook,
  python,
  replaceVars,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "imageio-ffmpeg";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "imageio";
    repo = "imageio-ffmpeg";
    tag = "v${version}";
    hash = "sha256-Yy2PTNBGPP/BAR7CZck/9qr2g/s4ntiuydqXz77hR7E=";
  };

  patches = [
    (replaceVars ./ffmpeg-path.patch {
      ffmpeg = lib.getExe ffmpeg;
    })
  ];

  nativeCheckInputs = [
    psutil
    pytestCheckHook
  ];

  postCheck = ''
    ${python.interpreter} << EOF
    from imageio_ffmpeg import get_ffmpeg_version
    assert get_ffmpeg_version() == '${ffmpeg.version}'
    EOF
  '';

  build-system = [ setuptools ];

  disabledTestPaths = [
    # network access
    "tests/test_io.py"
    "tests/test_special.py"
    "tests/test_terminate.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "imageio_ffmpeg" ];

  meta = {
    description = "FFMPEG wrapper for Python";
    homepage = "https://github.com/imageio/imageio-ffmpeg";
    changelog = "https://github.com/imageio/imageio-ffmpeg/releases/tag/${src.tag}";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.pmiddend ];
  };
}
