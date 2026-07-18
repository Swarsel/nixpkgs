{
  lib,
  fetchFromGitHub,
  alsa-lib,
  bash,
  clang,
  copyDesktopItems,
  ffmpeg,
  makeDesktopItem,
  mdk-sdk,
  ocl-icd,
  opencv,
  patchelf,
  pkg-config,
  qt6,
  rustPlatform,
}:
let
  lens-profiles = fetchFromGitHub {
    hash = "sha256-JjH7cGT9hzB9pv0W6FUPaejkiUj357IM2siJNrSHiYY=";
    owner = "gyroflow";
    repo = "lens_profiles";
    tag = "v36";
  };
in
rustPlatform.buildRustPackage rec {
  pname = "gyroflow";
  version = "1.6.3";

  src = fetchFromGitHub {
    owner = "gyroflow";
    repo = "gyroflow";
    tag = "v${version}";
    hash = "sha256-ncGbM8wIwnyLHp+oArgDnKCCGIeywdH7YGZPgRBLiJM=";
  };

  postPatch = ''
    substituteInPlace build.rs \
      --replace-fail 'println!("cargo:rustc-link-lib=static:+whole-archive=z")' ""
  '';

  nativeBuildInputs = [
    clang
    copyDesktopItems
    patchelf
    pkg-config
    rustPlatform.bindgenHook
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    alsa-lib
    bash
    ffmpeg
    mdk-sdk
    ocl-icd
    opencv
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtsvg
  ];

  cargoHash = "sha256-9UamQxrKVMSivhZ/cvRRCliaf3eFeHg5XPPtuaRKrg0=";
  # FFMPEG_DIR is used by ffmpeg-sys-next/build.rs and
  # gyroflow/build.rs.  ffmpeg-sys-next fails to build if this dir
  # does not contain ffmpeg *headers*.  gyroflow assumes that it
  # contains ffmpeg *libraries*, but builds fine as long as it is set
  # with any value.
  env.FFMPEG_DIR = ffmpeg.dev;
  # For qml-video-rs. It concatenates "lib/" to this value so it needs a trailing "/":
  env.MDK_SDK = "${mdk-sdk}/";

  # qml-video-rs and gyroflow assume that all Qt headers are installed
  # in a single (qtbase) directory.  Apart form QtCore and QtGui from
  # qtbase they need QtQuick and QtQml public and private headers from
  # qtdeclarative:
  # https://github.com/AdrianEddy/qml-video-rs/blob/bbf60090b966f0df2dd016e01da2ea78666ecea2/build.rs#L22-L40
  # https://github.com/gyroflow/gyroflow/blob/v1.5.4/build.rs#L163-L186
  # Additionally gyroflow needs QtQuickControls2:
  # https://github.com/gyroflow/gyroflow/blob/v1.5.4/build.rs#L173
  env.NIX_CFLAGS_COMPILE = toString [
    "-I${qt6.qtdeclarative}/include/QtQuick"
    "-I${qt6.qtdeclarative}/include/QtQuick/${qt6.qtdeclarative.version}"
    "-I${qt6.qtdeclarative}/include/QtQuick/${qt6.qtdeclarative.version}/QtQuick"
    "-I${qt6.qtdeclarative}/include/QtQml"
    "-I${qt6.qtdeclarative}/include/QtQml/${qt6.qtdeclarative.version}"
    "-I${qt6.qtdeclarative}/include/QtQml/${qt6.qtdeclarative.version}/QtQml"
    "-I${qt6.qtdeclarative}/include/QtQuickControls2"
  ];

  env.OPENCV_LINK_LIBS = "opencv_core,opencv_calib3d,opencv_dnn,opencv_features2d,opencv_imgproc,opencv_video,opencv_flann,opencv_imgcodecs,opencv_objdetect,opencv_stitching,png";
  # These variables are needed by gyroflow/build.rs.
  # OPENCV_LINK_LIBS is based on the value in gyroflow/_scripts/common.just, with opencv_dnn added to fix linking.
  env.OPENCV_LINK_PATHS = "${opencv}/lib";
  doCheck = false; # No tests.

  preCheck = ''
    # qml-video-rs/build.rs wants to overwrite it:
    find target -name libmdk.so.0 -exec chmod +w {} \;
  '';

  postInstall = ''
    mkdir -p $out/opt/Gyroflow
    cp -r resources $out/opt/Gyroflow/
    ln -s ${lens-profiles} $out/opt/Gyroflow/resources/camera_presets

    rm -rf $out/lib
    patchelf $out/bin/gyroflow --add-rpath ${mdk-sdk}/lib

    mv $out/bin/gyroflow $out/opt/Gyroflow/
    ln -s ../opt/Gyroflow/gyroflow $out/bin/

    install -D ${./gyroflow-open.sh} $out/bin/gyroflow-open
    install -Dm644 ${./gyroflow-mime.xml} $out/share/mime/packages/gyroflow.xml
    install -Dm644 resources/icon.svg $out/share/icons/hicolor/scalable/apps/gyroflow.svg
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "AudioVideo"
        "Video"
        "AudioVideoEditing"
        "Qt"
      ];

      comment = meta.description;
      desktopName = "Gyroflow";
      exec = "gyroflow-open %u";
      genericName = "Video stabilization using gyroscope data";
      icon = "gyroflow";
      mimeTypes = [ "application/x-gyroflow" ];
      name = "gyroflow";
      prefersNonDefaultGPU = true;
      startupNotify = true;
      startupWMClass = "gyroflow";
      terminal = false;
    })
  ];

  meta = {
    description = "Advanced gyro-based video stabilization tool";
    homepage = "https://gyroflow.xyz";

    license = with lib.licenses; [
      gpl3Plus
      cc0
    ];

    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
  };
}
