{
  lib,
  fetchPypi,
  fetchpatch2,
  ffmpeg,
  python3Packages,
  replaceVars,
  extras ? [
    "decompress"
  ],
}:

python3Packages.buildPythonApplication rec {
  pname = "streamlink";
  version = "8.4.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-9HfpSTM2vLfDorEO6nKmCumn9J6WitoNTQG/946sRLs=";
  };

  patches = [
    (replaceVars ./ffmpeg-path.patch {
      ffmpeg = lib.getExe ffmpeg;
    })
    # remove when bumping to >8.4.0
    (fetchpatch2 {
      hash = "sha256-9C4NedVyuk0ed3JvpKtvxei3Wo+r4SPlQXbBpoRXZ4k=";
      name = "fix-read-timeout-test.patch";
      url = "https://github.com/streamlink/streamlink/commit/a1875a2c85cef47ddf6b1375c3651d52c8e799a1.patch?full_index=1";
    })
  ];

  nativeBuildInputs = with python3Packages; [
    setuptools
  ];

  propagatedBuildInputs =
    with python3Packages;
    [
      certifi
      isodate
      lxml
      pycountry
      pycryptodome
      pysocks
      requests
      trio
      trio-websocket
      urllib3
      websocket-client
    ]
    ++ lib.flatten (lib.attrVals extras optional-dependencies);

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    mock
    requests-mock
    freezegun
    pytest-trio
    pytest-cov-stub
  ];

  disabledTests = [
    # requires ffmpeg to be in PATH
    "test_no_cache"
  ];

  optional-dependencies = with python3Packages; {
    decompress = urllib3.optional-dependencies.brotli ++ urllib3.optional-dependencies.zstd;
  };

  pyproject = true;

  meta = {
    description = "CLI for extracting streams from various websites to video player of your choosing";

    longDescription = ''
      Streamlink is a CLI utility that pipes videos from online
      streaming services to a variety of video players such as VLC, or
      alternatively, a browser.

      Streamlink is a fork of the livestreamer project.
    '';

    homepage = "https://streamlink.github.io/";
    changelog = "https://streamlink.github.io/changelog.html";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      zraexy
      DeeUnderscore
    ];

    mainProgram = "streamlink";
  };
}
