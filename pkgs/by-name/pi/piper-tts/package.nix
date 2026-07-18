{
  lib,
  fetchFromGitHub,
  # runtime
  espeak-ng,
  # build time
  pkg-config,
  python3Packages,
  withAlignment ? true,
  withHTTP ? true,
  # extras
  withTrain ? true,
}:

let
  # https://github.com/OHF-Voice/piper1-gpl/blob/v1.3.0/CMakeLists.txt#L33-L40
  espeak-ng' = espeak-ng.override {
    asyncSupport = false;
    klattSupport = false;
    mbrolaSupport = false;
    pcaudiolibSupport = false;
    sonicSupport = false;
    speechPlayerSupport = false;
  };
in

python3Packages.buildPythonApplication rec {
  pname = "piper-tts";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "OHF-Voice";
    repo = "piper1-gpl";
    tag = "v${version}";
    hash = "sha256-FHO+1d1iJimc6KweY/O6lEvWqGCyUwnDrslEfkxYR7A=";
  };

  patches = [
    # https://github.com/OHF-Voice/piper1-gpl/pull/17
    ./cmake-system-libs.patch
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    espeak-ng'
  ];

  env.CMAKE_ARGS = toString [
    (lib.cmakeFeature "UCD_STATIC_LIB" "${espeak-ng'.ucd-tools}/libucd.a")
  ];

  postBuild = lib.optionalString withTrain ''
    cythonize --inplace src/piper/train/vits/monotonic_align/core.pyx
  '';

  postInstall = ''
    ln -s ${espeak-ng'}/share/espeak-ng-data $out/${python3Packages.python.sitePackages}/piper/
  ''
  + lib.optionalString withTrain ''
    train=$out/${python3Packages.python.sitePackages}/piper/train/vits
    rm -v src/piper/train/vits/monotonic_align/{Makefile,setup.py,core.c,core.pyx}
    cp -Rv src/piper/train/vits $train/
  '';

  build-system =
    with python3Packages;
    [
      cmake
      ninja
      scikit-build
      setuptools
    ]
    ++ lib.optionals withTrain [
      cython
      distutils
    ];

  dependencies =
    with python3Packages;
    [
      onnxruntime
      pathvalidate
    ]
    ++ lib.optionals withTrain optional-dependencies.train
    ++ lib.optionals withHTTP optional-dependencies.http
    ++ lib.optionals withAlignment optional-dependencies.alignment;

  dontUseCmakeConfigure = true;

  optional-dependencies = {
    alignment = with python3Packages; [
      onnx
    ];

    http = with python3Packages; [
      flask
    ];

    train =
      with python3Packages;
      [
        jsonargparse
        librosa
        lightning
        pysilero-vad
        tensorboard
        tensorboardx
        torch
      ]
      ++ jsonargparse.optional-dependencies.signatures;
  };

  pyproject = true;

  meta = {
    description = "Fast, local neural text to speech system";
    homepage = "https://github.com/OHF-Voice/piper1-gpl";
    changelog = "https://github.com/OHF-Voice/piper1-gpl/releases/tag/v${version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ hexa ];
    mainProgram = "piper";
  };
}
