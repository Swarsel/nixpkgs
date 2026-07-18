{
  lib,
  stdenv,
  fetchFromGitLab,
  bison,
  boost,
  cmake,
  config,
  cudaPackages,
  eigen,
  # For panorama and focus stacking
  enblend-enfuse,
  exiftool,
  exiv2,
  expat,
  fetchgit,
  flex,
  gitUpdater,
  gnumake,
  hugin,
  imagemagick,
  jasper,
  kdePackages,
  lcms2,
  lensfun,
  libGLU,
  libGLX,
  libgphoto2,
  libheif,
  libjpeg,
  libjxl,
  liblqr1,
  libpng,
  libtiff,
  libusb1,
  libxml2,
  libxslt,
  ninja,
  opencv,
  # For `digitaglinktree`
  perl,
  pkg-config,
  runtimeShell,
  sqlite,
  wrapGAppsHook3,
  x265,
  enableCuda ? config.cudaSupport,
}:

let
  testData = fetchgit {
    fetchLFS = true;
    hash = "sha256-SvsmcniDRorwu9x9OLtHD9ftgquyoE5Kl8qDgqi1XdQ=";
    rev = "d02dd20b23cc279792325a0f03d21688547a7a59";
    url = "https://invent.kde.org/graphics/digikam-test-data.git";
  };
in

stdenv.mkDerivation (finalAttrs: {
  pname = "digikam";
  version = "9.1.0";

  src = fetchFromGitLab {
    owner = "graphics";
    repo = "digikam";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rrAqHSG7AsyG8DM0zYfyuGyu6jI/ZDmSYco91nhdmhQ=";
    domain = "invent.kde.org";
  };

  patches = [
    ./disable-tests-download.patch
  ];

  postPatch = ''
    substituteInPlace \
      core/dplugins/bqm/custom/userscript/userscript.cpp \
      core/utilities/import/backend/cameracontroller.cpp \
      --replace-fail '"/bin/bash"' ${lib.escapeShellArg "\"${runtimeShell}\""}
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    ninja
    kdePackages.extra-cmake-modules
    flex
    bison
    kdePackages.wrapQtAppsHook
    wrapGAppsHook3
  ];

  # Based on <https://www.digikam.org/api/index.html#externaldeps>,
  # but it doesn’t have everything, so you also have to check the
  # CMake files…
  #
  # We list non‐Qt dependencies first to override Qt’s propagated
  # build inputs.
  buildInputs = [
    opencv.cxxdev
    libtiff
    libpng
    # TODO: Figure out how on earth to get it to pick up libjpeg8 for
    # lossy DNG support.
    libjpeg
    libheif
    libjxl
    boost
    lcms2
    expat
    exiv2
    libxml2
    libxslt
    # Qt WebEngine uses and propagates FFmpeg, and if it’s a
    # different version it causes linker warnings.
    #ffmpeg
    jasper
    eigen
    lensfun
    liblqr1
    libgphoto2
    libusb1
    imagemagick
    x265
    libGLX
    libGLU

    kdePackages.qtbase
    kdePackages.qtnetworkauth
    kdePackages.qtscxml
    kdePackages.qtsvg
    kdePackages.qtwayland
    kdePackages.qtwebengine
    kdePackages.qt5compat
    kdePackages.qtmultimedia

    kdePackages.kconfig
    kdePackages.kxmlgui
    kdePackages.ki18n
    kdePackages.kwindowsystem
    kdePackages.kservice
    kdePackages.solid
    kdePackages.kcoreaddons
    kdePackages.knotifyconfig
    kdePackages.knotifications
    kdePackages.threadweaver
    kdePackages.kiconthemes
    kdePackages.kfilemetadata
    kdePackages.kcalendarcore
    kdePackages.kio
    kdePackages.sonnet
    # libksane and akonadi-contacts do not yet work when building for
    # Qt 6.
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_WITH_QT6" true)
    (lib.cmakeBool "BUILD_TESTING" finalAttrs.finalPackage.doCheck)
    (lib.cmakeBool "ENABLE_KFILEMETADATASUPPORT" true)
    #(lib.cmakeBool "ENABLE_AKONADICONTACTSUPPORT" true)
    (lib.cmakeBool "ENABLE_MEDIAPLAYER" true)
    (lib.cmakeBool "ENABLE_APPSTYLES" true)
    (lib.optionals enableCuda "-DCUDA_TOOLKIT_ROOT_DIR=${cudaPackages.cudatoolkit}")
  ];

  postConfigure = lib.optionalString finalAttrs.finalPackage.doCheck ''
    ln -s ${testData} $cmakeDir/test-data
  '';

  # Tests segfault for some reason…
  # TODO: Get them working.
  doCheck = false;
  checkInputs = [ kdePackages.qtdeclarative ];

  preFixup = ''
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
    qtWrapperArgs+=(--prefix PATH : ${
      lib.makeBinPath [
        gnumake
        hugin
        enblend-enfuse
        exiftool
      ]
    })
    qtWrapperArgs+=(--suffix DK_PLUGIN_PATH : ${placeholder "out"}/${kdePackages.qtbase.qtPluginPrefix}/digikam)
    substituteInPlace $out/bin/digitaglinktree \
      --replace "/usr/bin/perl" "${lib.getExe perl}" \
      --replace "/usr/bin/sqlite3" "${lib.getExe sqlite}"
  '';

  dontWrapGApps = true;
  # over 3h in a normal build slot (2 cores
  requiredSystemFeatures = [ "big-parallel" ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = {
    description = "Photo management application";
    homepage = "https://www.digikam.org/";
    changelog = "${finalAttrs.src.meta.homepage}-/blob/master/project/NEWS.${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = with lib.maintainers; [ philipdb ];
    platforms = lib.platforms.linux;
    mainProgram = "digikam";
  };
})
