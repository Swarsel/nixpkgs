{
  lib,
  fetchFromGitHub,
  ffmpeg,
  gitUpdater,
  python3Packages,
  replaceVars,
  sox,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "r128gain";
  version = "1.0.7";

  src = fetchFromGitHub {
    owner = "desbma";
    repo = "r128gain";
    rev = finalAttrs.version;
    sha256 = "sha256-JyKacDqjIKTNl2GjbJPkgbakF8HR4Jd4czAtOaemDH8=";
  };

  patches = [
    (replaceVars ./ffmpeg-location.patch {
      inherit ffmpeg;
    })
  ];

  # Testing downloads media files for testing, which requires the
  # sandbox to be disabled.
  doCheck = false;

  nativeCheckInputs = with python3Packages; [
    requests
    sox
  ];

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    crcmod
    ffmpeg-python
    mutagen
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "r128gain" ];
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Fast audio loudness scanner & tagger (ReplayGain v2 / R128)";
    homepage = "https://github.com/desbma/r128gain";
    license = lib.licenses.lgpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "r128gain";
  };
})
