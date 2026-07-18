{
  lib,
  fetchPypi,
  ffmpeg-headless,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "scdl";
  version = "3.0.6";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-kAvK1KqfVK6axQXTkBtcMxc7OHLPYNfIyy2n+97LhB4=";
  };

  # No tests in repository
  doCheck = false;
  build-system = [ python3Packages.setuptools ];

  dependencies =
    with python3Packages;
    [
      docopt-ng
      mutagen
      soundcloud-v2
      yt-dlp
    ]
    ++ yt-dlp.optional-dependencies.curl-cffi;

  # Ensure ffmpeg is available in $PATH:
  makeWrapperArgs =
    let
      packagesToBinPath = [ ffmpeg-headless ];
    in
    [
      ''--prefix PATH : "${lib.makeBinPath packagesToBinPath}"''
    ];

  pyproject = true;
  pythonImportsCheck = [ "scdl" ];

  meta = {
    description = "Download Music from Soundcloud";
    homepage = "https://github.com/flyingrub/scdl";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    mainProgram = "scdl";
  };
})
