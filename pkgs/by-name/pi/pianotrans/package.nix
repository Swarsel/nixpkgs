{
  lib,
  fetchFromGitHub,
  ffmpeg,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "pianotrans";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "azuwis";
    repo = "pianotrans";
    rev = "v${finalAttrs.version}";
    hash = "sha256-gRbyUQmPtGvx5QKAyrmeJl0stp7hwLBWwjSbJajihdE=";
  };

  # Project has no tests
  doCheck = false;
  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    piano-transcription-inference
    resampy
    tkinter
    torch
  ];

  makeWrapperArgs = [
    ''--prefix PATH : "${lib.makeBinPath [ ffmpeg ]}"''
  ];

  pyproject = true;

  meta = {
    description = "Simple GUI for ByteDance's Piano Transcription with Pedals";
    homepage = "https://github.com/azuwis/pianotrans";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ azuwis ];
    mainProgram = "pianotrans";
  };
})
