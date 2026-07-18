{
  lib,
  stdenv,
  fetchFromGitHub,
  # Libraries
  boost,
  cmake,
  # Transport
  curl,
  # GUI/Desktop
  dbus,
  # GStreamer
  glib-networking,
  glibmm,
  gsettings-desktop-schemas,
  gst_all_1,
  # Testing
  gtest,
  hicolor-icon-theme,
  jsoncpp,
  libappindicator-gtk3,
  libbsd,
  libnotify,
  libxdg_basedir,
  # User-agent info
  lsb-release,
  makeWrapper,
  pkg-config,
  # rt2rtng
  python3,
  # Fixup
  wrapGAppsHook3,
  wxwidgets_3_2,
}:

let
  gstInputs = with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    gst-libav
  ];
  # For the rt2rtng utility for converting bookmark file to -ng format
  pythonInputs = with python3.pkgs; [
    python
    lxml
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "radiotray-ng";
  version = "0.2.10.1";

  src = fetchFromGitHub {
    owner = "ebruck";
    repo = "radiotray-ng";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GYSacYKS0az5sqPqZhnuTZOT9NSzW+P9o5r5p0RhTtI=";
  };

  patches = [
    ./no-dl-googletest.patch
  ];

  postPatch = ''
    for x in package/CMakeLists.txt include/radiotray-ng/common.hpp data/*.desktop; do
      substituteInPlace $x --replace /usr $out
    done
    substituteInPlace package/CMakeLists.txt --replace /etc/xdg/autostart $out/etc/xdg/autostart

    # jsoncpp 1.9.7 only exports std::string_view overloads under C++17
    substituteInPlace CMakeLists.txt \
      --replace-fail "set(CMAKE_CXX_STANDARD 14)" "set(CMAKE_CXX_STANDARD 17)"

    # We don't find the radiotray-ng-notification icon otherwise
    substituteInPlace data/radiotray-ng.desktop \
      --replace radiotray-ng-notification radiotray-ng-on
    substituteInPlace data/rtng-bookmark-editor.desktop \
      --replace radiotray-ng-notification radiotray-ng-on
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapGAppsHook3
    makeWrapper
  ];

  buildInputs = [
    curl
    boost
    jsoncpp
    libbsd
    glibmm
    hicolor-icon-theme
    gsettings-desktop-schemas
    libappindicator-gtk3
    libnotify
    libxdg_basedir
    lsb-release
    wxwidgets_3_2
    # for https gstreamer / libsoup
    glib-networking
  ]
  ++ gstInputs
  ++ pythonInputs;

  cmakeFlags = [
    (lib.cmakeBool "BUILD_TESTS" finalAttrs.doCheck)
  ];

  # 'wxFont::wxFont(int, int, int, int, bool, const wxString&, wxFontEncoding)' is deprecated
  env.NIX_CFLAGS_COMPILE = "-Wno-error=deprecated-declarations";
  doCheck = !stdenv.hostPlatform.isAarch64; # single failure that I can't explain
  nativeCheckInputs = [ gtest ];

  preFixup = ''
    gappsWrapperArgs+=(--suffix PATH : ${lib.makeBinPath [ dbus ]})
    wrapProgram $out/bin/rt2rtng --prefix PYTHONPATH : $PYTHONPATH
  '';

  meta = {
    description = "Internet radio player for linux";
    homepage = "https://github.com/ebruck/radiotray-ng";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.somasis ];
    platforms = lib.platforms.linux;
  };
})
