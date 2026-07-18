{
  lib,
  fetchFromGitHub,
  ffmpeg,
  imagemagick,
  python3Packages,
  # patches
  replaceVars,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "compress-pptx";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "slhck";
    repo = "compress-pptx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+67EdAEWsRY11Pkie6AOz7Sl7MSTMGxZoQYS+M2x07Y=";
  };

  patches = [
    (replaceVars ./inject-dependency-paths.patch {
      ffmpeg = lib.getExe ffmpeg;
      magick = lib.getExe imagemagick;
    })
  ];

  nativeCheckInputs = [
    python3Packages.pytestCheckHook
  ];

  build-system = with python3Packages; [ uv-build ];

  dependencies = with python3Packages; [
    ffmpeg-progress-yield
    tqdm
  ];

  pyproject = true;

  meta = {
    description = "Compress PPTX files";

    longDescription = ''
      Compress a PPTX or POTX file, converting all PNG/TIFF images to lossy
      JPEGs.
    '';

    homepage = "https://github.com/slhck/compress-pptx";
    changelog = "https://github.com/slhck/compress-pptx/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ artur-sannikov ];
    mainProgram = "compress-pptx";
  };
})
