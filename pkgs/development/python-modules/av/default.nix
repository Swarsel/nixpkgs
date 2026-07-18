{
  lib,
  # dependencies
  fetchurl,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cython,
  # buildInputs
  ffmpeg-headless,
  linkFarm,
  numpy,
  pillow,
  # nativeBuildInputs
  pkg-config,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "av";
  version = "17.0.1";

  src = fetchFromGitHub {
    owner = "PyAV-Org";
    repo = "PyAV";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IS+qSwvpNbhOazkgZh9hzzaTLxSgU7uZjGmaOIkhskc=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ ffmpeg-headless ];

  nativeCheckInputs = [
    numpy
    pillow
    pytestCheckHook
  ];

  preCheck =
    let
      # Update with `./update-test-samples.bash` if necessary.
      testSamples = linkFarm "pyav-test-samples" (
        lib.mapAttrs (_: fetchurl) (lib.importTOML ./test-samples.toml)
      );
    in
    ''
      # ensure we import the built version
      rm -r av
      ln -s ${testSamples} tests/assets
    '';

  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;

  build-system = [
    cython
    setuptools
  ];

  disabledTests = [
    # network access
    "test_index_entries_len_webm"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "av"
    "av.audio"
    "av.buffer"
    "av.codec"
    "av.container"
    "av._core"
    "av.datasets"
    "av.descriptor"
    "av.dictionary"
    "av.error"
    "av.filter"
    "av.format"
    "av.frame"
    "av.logging"
    "av.option"
    "av.packet"
    "av.plane"
    "av.stream"
    "av.subtitles"
    "av.utils"
    "av.video"
  ];

  meta = {
    description = "Pythonic bindings for FFmpeg";
    homepage = "https://github.com/PyAV-Org/PyAV";
    changelog = "https://github.com/PyAV-Org/PyAV/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    mainProgram = "pyav";
  };
})
