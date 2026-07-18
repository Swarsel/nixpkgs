{
  lib,
  fetchPypi,
  ffmpeg,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "ffmpeg-normalize";
  version = "1.41.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-v5icrioELMBi2uJSdoojgY4EMnwHGxncanrT6GpSpSc=";
    pname = "ffmpeg_normalize";
  };

  postPatch = with python3Packages; ''
    substituteInPlace pyproject.toml \
      --replace-fail \
      'colorlog==6.7.0' \
      'colorlog==${colorlog.version}'
  '';

  checkPhase = ''
    runHook preCheck

    $out/bin/ffmpeg-normalize --help > /dev/null

    runHook postCheck
  '';

  build-system = with python3Packages; [ uv-build ];

  dependencies =
    with python3Packages;
    [
      colorlog
      ffmpeg-progress-yield
      mutagen
    ]
    ++ [ ffmpeg ];

  pyproject = true;

  meta = {
    description = "Normalize audio via ffmpeg";
    homepage = "https://github.com/slhck/ffmpeg-normalize";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      luftmensch-luftmensch
      prusnak
    ];

    mainProgram = "ffmpeg-normalize";
  };
}
