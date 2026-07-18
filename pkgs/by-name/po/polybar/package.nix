{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  cairo,
  cmake,
  config,
  curl,
  fetchpatch,
  i3,
  jsoncpp,
  libmpdclient,
  libnl,
  libpthread-stubs,
  libpulseaudio,
  libuv,
  libxcb,
  libxcb-cursor,
  libxcb-image,
  libxcb-render-util,
  libxcb-util,
  libxcb-wm,
  libxdmcp,
  makeWrapper,
  pkg-config,
  python3,
  python3Packages, # sphinx-build
  removeReferencesTo,
  wirelesstools,
  xcbproto,
  xcbutilxrm,
  # override the variables ending in 'Support' to enable or disable modules
  alsaSupport ? true,
  githubSupport ? false,
  i3Support ? false,
  iwSupport ? false,
  mpdSupport ? false,
  nlSupport ? true,
  pulseSupport ? config.pulseaudio or false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "polybar";
  version = "3.7.2";

  src = fetchFromGitHub {
    owner = "polybar";
    repo = "polybar";
    tag = finalAttrs.version;
    hash = "sha256-5PYKl6Hi4EYEmUBwkV0rLiwxNqIyR5jwm495YnNs0gI=";
    fetchSubmodules = true;
  };

  patches = [
    # FIXME: remove after version update
    (fetchpatch {
      name = "gcc15-cstdint-fix.patch";
      sha256 = "sha256-Mf9R4u1Kq4yqLqTFD5ZoLjrK+GmlvtSsEyRFRCiQ72U=";
      url = "https://github.com/polybar/polybar/commit/f99e0b1c7a5b094f5a04b14101899d0cb4ece69d.patch";
    })

    ./remove-hardcoded-etc.diff
  ];

  # Replace hardcoded /etc when copying and reading the default config.
  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail "/etc" $out
    substituteAllInPlace src/utils/file.cpp
    # Fix gcc15 build: i3ipcpp forces -std=c++11 but the jsoncpp library was
    # compiled with C++17 (JSONCPP_HAS_STRING_VIEW=1), causing ABI mismatch.
    # The i3ipcpp code resolves operator[](const char*) but the library only
    # exports operator[](std::string_view). Bump i3ipcpp to C++17 to match.
    substituteInPlace lib/i3ipcpp/CMakeLists.txt --replace-fail \
      "-std=c++11" \
      "-std=c++17"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    python3Packages.sphinx
    removeReferencesTo
  ]
  ++ lib.optional i3Support makeWrapper;

  buildInputs = [
    cairo
    libuv
    libxdmcp
    libpthread-stubs
    libxcb
    python3
    xcbproto
    libxcb-util
    libxcb-cursor
    libxcb-image
    libxcb-render-util
    libxcb-wm
    xcbutilxrm
  ]
  ++ lib.optional alsaSupport alsa-lib
  ++ lib.optional githubSupport curl
  ++ lib.optional mpdSupport libmpdclient
  ++ lib.optional pulseSupport libpulseaudio
  ++ lib.optional iwSupport wirelesstools
  ++ lib.optional nlSupport libnl
  ++ lib.optionals i3Support [
    jsoncpp
    i3
  ];

  postInstall = ''
    remove-references-to -t ${stdenv.cc} $out/bin/polybar
  ''
  + (lib.optionalString i3Support ''
    wrapProgram $out/bin/polybar \
      --prefix PATH : "${i3}/bin"
  '');

  meta = {
    description = "Fast and easy-to-use tool for creating status bars";

    longDescription = ''
      Polybar aims to help users build beautiful and highly customizable
      status bars for their desktop environment, without the need of
      having a black belt in shell scripting.
    '';

    homepage = "https://polybar.github.io/";
    changelog = "https://github.com/polybar/polybar/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      moni
    ];

    platforms = lib.platforms.linux;
    mainProgram = "polybar";
  };
})
