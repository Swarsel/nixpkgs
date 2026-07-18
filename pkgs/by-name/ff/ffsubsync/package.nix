{
  lib,
  fetchFromGitHub,
  ffmpeg,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "ffsubsync";
  version = "0.4.31";

  src = fetchFromGitHub {
    owner = "smacke";
    repo = "ffsubsync";
    tag = finalAttrs.version;
    hash = "sha256-j9E4h2de2EOtYpuxKFbPOxZ5FBRO0EkbZhJdx5RiPn8=";
  };

  nativeCheckInputs = with python3.pkgs; [ pytestCheckHook ];
  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    auditok
    charset-normalizer
    faust-cchardet
    ffmpeg-python
    numpy
    pysubs2
    chardet
    rich
    setuptools
    six
    srt
    tqdm
    typing-extensions
    webrtcvad
  ];

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    "${ffmpeg}/bin"
  ];

  pyproject = true;
  pythonImportsCheck = [ "ffsubsync" ];

  meta = {
    description = "Automagically synchronize subtitles with video";
    homepage = "https://github.com/smacke/ffsubsync";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "ffsubsync";
  };
})
