{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  decorator,
  imageio,
  imageio-ffmpeg,
  numpy,
  proglog,
  # tests
  pytest-timeout,
  pytestCheckHook,
  python-dotenv,
  requests,
  # build-system
  setuptools,
  tqdm,
}:

buildPythonPackage rec {
  pname = "moviepy";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "Zulko";
    repo = "moviepy";
    tag = "v${version}";
    hash = "sha256-3vt/EyEOv6yNPgewkgcWcjM0TbQ6IfkR6nytS/WpRyg=";
  };

  nativeCheckInputs = [
    pytest-timeout
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    decorator
    imageio
    imageio-ffmpeg
    numpy
    proglog
    python-dotenv
    requests
    tqdm
  ];

  disabledTestPaths = [
    "tests/test_compositing.py"
    "tests/test_fx.py"
    "tests/test_ImageSequenceClip.py"
    "tests/test_TextClip.py"
    "tests/test_VideoClip.py"
    "tests/test_videotools.py"
  ];

  disabledTests = [
    # stalls
    "test_doc_examples"
    # video orientation mismatch, 0 != 180
    "test_PR_529"
    # video orientation [1920, 1080] != [1080, 1920]
    "test_ffmpeg_parse_video_rotation"
    "test_correct_video_rotation"
    # media duration mismatch: assert 230.0 == 30.02
    "test_ffmpeg_parse_infos_decode_file"
    # Failed: DID NOT RAISE <class 'OSError'>
    "test_ffmpeg_resize"
    "test_ffmpeg_stabilize_video"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Failed: Timeout >30.0s
    "test_issue_1682"
  ];

  pyproject = true;
  # See https://github.com/NixOS/nixpkgs/issues/381908 and https://github.com/NixOS/nixpkgs/issues/385450.
  pytestFlags = [ "--timeout=600" ];
  pythonImportsCheck = [ "moviepy" ];
  pythonRelaxDeps = [ "pillow" ];

  meta = {
    description = "Video editing with Python";
    homepage = "https://zulko.github.io/moviepy/";
    changelog = "https://github.com/Zulko/moviepy/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
