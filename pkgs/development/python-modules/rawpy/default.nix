{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cython,
  # tests
  imageio,
  # buildInputs
  libraw,
  # dependencies
  numpy,
  # nativeBuildInputs
  pkg-config,
  pytestCheckHook,
  scikit-image,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "rawpy";
  version = "0.27.0";

  src = fetchFromGitHub {
    owner = "letmaik";
    repo = "rawpy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zM6S1oCOy6AWpaGgdgAqOUGW3rQ0Q9CxKMJoQTJPJIA=";
  };

  # cmake is only needed to build libraw when `RAWPY_USE_SYSTEM_LIBRAW` is disabled
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"cmake",' ""
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libraw
  ];

  env = {
    RAWPY_USE_SYSTEM_LIBRAW = 1;
  };

  nativeCheckInputs = [
    imageio
    pytestCheckHook
    scikit-image
  ];

  # Delete the source files to load the library from the installed folder instead of the source files
  preCheck = ''
    rm -rf rawpy
  '';

  build-system = [
    cython
    numpy
    setuptools
  ];

  dependencies = [
    numpy
  ];

  disabledTests = [
    # rawpy._rawpy.LibRawFileUnsupportedError: b'Unsupported file format or not RAW file'
    "testCropSizeSigma"
    "testFoveonFileOpenAndPostProcess"
    "testThumbExtractBitmap"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "rawpy"
    "rawpy._rawpy"
  ];

  meta = {
    description = "RAW image processing for Python, a wrapper for libraw";
    homepage = "https://github.com/letmaik/rawpy";

    license = with lib.licenses; [
      lgpl21Only
      mit
    ];

    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
