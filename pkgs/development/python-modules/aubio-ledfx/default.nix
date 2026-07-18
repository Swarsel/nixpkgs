{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  ffmpeg-headless,
  libsamplerate,
  libsndfile,
  meson-python,
  numpy,
  pkg-config,
  pytestCheckHook,
  rubberband,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "aubio-ledfx";
  version = "0.4.11";

  src = fetchFromGitHub {
    owner = "LedFx";
    repo = "aubio-ledfx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ec6QiTj1AOza+ggJPl3EULNDB/rrpCDZW0HaSywy/4E=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libsamplerate
    libsndfile
  ]
  ++ lib.optionals stdenv.targetPlatform.isLinux [
    ffmpeg-headless
  ]
  ++ lib.optionals (!stdenv.targetPlatform.isLinux) [
    rubberband
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    meson-python
    setuptools
  ];

  dependencies = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "aubio" ];

  meta = {
    description = "Collection of tools for music analysis";
    homepage = "https://github.com/LedFx/aubio-ledfx";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
})
