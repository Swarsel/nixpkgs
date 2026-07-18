{
  lib,
  stdenv,
  fetchurl,
  # nativeBuildInputs
  cmake,
  ffmpeg,
  gettext,
  gphoto2,
  # buildInputs
  guvcview,
  kdePackages,
  libgphoto2,
  libsForQt5,
  libv4l,
  libxml2,
  ninja,
  pkg-config,
  v4l-utils,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qstopmotion";
  version = "2.5.2";

  src = fetchurl {
    url = "mirror://sourceforge/project/qstopmotion/Version_${
      lib.replaceStrings [ "." ] [ "_" ] finalAttrs.version
    }/qstopmotion-${finalAttrs.version}-Source.tar.gz";

    hash = "sha256-jyBUyadkSuQKXOrr5XZ1jy6of1Qw8S2HPxuOrPc7RnE=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail \
        "find_package(Qt5 REQUIRED COMPONENTS Core Widgets Xml" \
        "find_package(Qt5 REQUIRED COMPONENTS Core Widgets Xml Multimedia" \
      --replace-fail \
        "cmake_minimum_required(VERSION 3.0.2)" \
        "cmake_minimum_required(VERSION 3.5)"
    grep -rl 'qwt' . | xargs sed -i 's@<qwt/qwt_slider.h>@<qwt_slider.h>@g'
  '';

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    gettext
    gphoto2
    libgphoto2
    libsForQt5.wrapQtAppsHook
    libv4l
    libxml2
    ninja
    pkg-config
  ];

  buildInputs = [
    (guvcview.override {
      useGtk = false;
      useQt = true;
    })
    libsForQt5.qtbase
    libsForQt5.qtimageformats
    libsForQt5.qtmultimedia
    libsForQt5.qtquickcontrols
    libsForQt5.qtxmlpatterns
    libsForQt5.qwt
    libv4l
    v4l-utils
  ];

  qtWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [ ffmpeg ])
  ];

  meta = {
    description = "Create stopmotion animation with a (web)camera";

    longDescription = ''
      Qstopmotion is a tool to create stopmotion
      animation. Its users are able to create stop-motions from pictures
      imported from a camera or from the harddrive and export the
      animation to different video formats such as mpeg or avi.
    '';

    homepage = "http://www.qstopmotion.org";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.gnu ++ lib.platforms.linux;
    mainProgram = "qstopmotion";
  };
})
