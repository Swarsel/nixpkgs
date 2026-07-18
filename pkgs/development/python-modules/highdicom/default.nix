{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch2,
  numpy,
  pillow,
  pydicom,
  pyjpegls,
  pylibjpeg,
  pylibjpeg-libjpeg,
  pylibjpeg-openjpeg,
  pytestCheckHook,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "highdicom";
  version = "0.27.0";

  src = fetchFromGitHub {
    owner = "MGHComputationalPathology";
    repo = "highdicom";
    tag = "v${version}";
    hash = "sha256-Tfy7u5MVapRE24CZLFzTnYChnH9JJ9V7FuUhDoktBFc=";
  };

  patches = [
    # Fix time-of-day-dependent failure in series_time validation.
    (fetchpatch2 {
      hash = "sha256-1h9xmcezxuvHw54t4kLahDB62d0XHzEyrmHmPf6NW7M=";
      url = "https://github.com/ImagingDataCommons/highdicom/commit/e9e3f2514a74b0d4be736cff222c934ef66d67ff.patch?full_index=1";
    })
  ];

  nativeCheckInputs = [ pytestCheckHook ] ++ optional-dependencies.libjpeg;

  preCheck = ''
    export HOME=$TMP/test-home
    mkdir -p $HOME/.pydicom/
    ln -s ${pydicom.passthru.pydicom-data}/data_store/data $HOME/.pydicom/data
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
    pillow
    pydicom
    pyjpegls
    typing-extensions
  ];

  optional-dependencies = {
    libjpeg = [
      pylibjpeg
      pylibjpeg-libjpeg
      pylibjpeg-openjpeg
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "highdicom"
    "highdicom.legacy"
    "highdicom.ann"
    "highdicom.ko"
    "highdicom.pm"
    "highdicom.pr"
    "highdicom.seg"
    "highdicom.sr"
    "highdicom.sc"
  ];

  meta = {
    description = "High-level DICOM abstractions for Python";
    homepage = "https://highdicom.readthedocs.io";
    changelog = "https://github.com/ImagingDataCommons/highdicom/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
