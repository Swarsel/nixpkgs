{
  lib,
  stdenv,
  fetchFromGitHub,
  aravis,
  catch2,
  cmake,
  elfutils,
  glib,
  gobject-introspection,
  graphviz,
  gst_all_1,
  libselinux,
  libsepol,
  libunwind,
  libusb1,
  libuuid,
  libzip,
  meson,
  orc,
  pcre,
  pkg-config,
  qt5,
  runtimeShell,
  sphinx,
  wrapGAppsHook3,
  zstd,
  withAravis ? true,
  withAravisUsbVision ? withAravis,
  # needs pkg_resources
  withDoc ? false,
  withGui ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tiscamera";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "TheImagingSource";
    repo = "tiscamera";
    rev = "v-tiscamera-${finalAttrs.version}";
    hash = "sha256-3qAPUcP+Rh1aA1qNWq0NWMpJftinm32r52esikH804Y=";
  };

  postPatch = ''
    cp ${catch2}/include/catch2/catch.hpp external/catch/catch.hpp

    substituteInPlace ./data/udev/80-theimagingsource-cameras.rules.in \
      --replace "/bin/sh" "${runtimeShell}/bin/sh" \
      --replace "typically /usr/bin/" "" \
      --replace "typically /usr/share/theimagingsource/tiscamera/uvc-extension/" ""
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapGAppsHook3
    gobject-introspection
  ]
  ++ lib.optionals withDoc [
    sphinx
    graphviz
  ]
  ++ lib.optionals withAravis [
    meson
  ]
  ++ lib.optionals withGui [
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    elfutils
    libselinux
    libsepol
    libunwind
    libusb1
    libuuid
    libzip
    orc
    pcre
    zstd
    glib
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
  ]
  ++ lib.optionals withAravis [
    aravis
  ]
  ++ lib.optionals withGui [
    qt5.qtbase
  ];

  cmakeFlags = [
    "-DTCAM_BUILD_GST_1_0=ON"
    "-DTCAM_BUILD_TOOLS=ON"
    "-DTCAM_BUILD_V4L2=ON"
    "-DTCAM_BUILD_LIBUSB=ON"
    "-DTCAM_BUILD_TESTS=ON"
    "-DTCAM_BUILD_ARAVIS=${if withAravis then "ON" else "OFF"}"
    "-DTCAM_BUILD_DOCUMENTATION=${if withDoc then "ON" else "OFF"}"
    "-DTCAM_BUILD_WITH_GUI=${if withGui then "ON" else "OFF"}"
    "-DTCAM_DOWNLOAD_MESON=OFF"
    "-DTCAM_INTERNAL_ARAVIS=OFF"
    "-DTCAM_ARAVIS_USB_VISION=${if withAravis && withAravisUsbVision then "ON" else "OFF"}"
    "-DTCAM_INSTALL_FORCE_PREFIX=ON"
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.10"
  ];

  env = {
    CXXFLAGS = toString [
      "-include"
      "cstdint"
    ];

    # wrapGAppsHook3: make sure we add ourselves to the introspection
    # and gstreamer paths.
    GI_TYPELIB_PATH = "${placeholder "out"}/lib/girepository-1.0";
    GST_PLUGIN_SYSTEM_PATH_1_0 = "${placeholder "out"}/lib/gstreamer-1.0";
    QT_PLUGIN_PATH = lib.optionalString withGui "${qt5.qtbase.bin}/${qt5.qtbase.qtPluginPrefix}";
  };

  doCheck = true;
  # gstreamer tests requires, besides gst-plugins-bad, plugins installed by this expression.
  checkPhase = "ctest --force-new-ctest-process -E gstreamer";
  doInstallCheck = true;

  preFixup = ''
    gappsWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  dontWrapQtApps = true;
  hardeningDisable = [ "format" ];

  meta = {
    description = "Linux sources and UVC firmwares for The Imaging Source cameras";
    homepage = "https://github.com/TheImagingSource/tiscamera";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ jraygauthier ];
    platforms = lib.platforms.linux;
  };
})
