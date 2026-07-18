{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  # Native Build Inputs
  cmake,
  docutils,
  glib,
  libnl,
  libpulseaudio,
  libselinux,
  libsepol,
  libx11,
  libxau,
  libxcb,
  libxcb-util,
  libxcb-wm,
  libxdmcp,
  lua5,
  makeWrapper,
  pcre2,
  pkg-config,
  udev,
  util-linux,
  # Dependencies
  yajl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "luastatus";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "shdown";
    repo = "luastatus";
    rev = "v${finalAttrs.version}";
    hash = "sha256-whO5pjUPaCwEb2GDCIPnTk39MejSQOoRRQ5kdYEQ0Pc=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required (VERSION 3.1.3)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    libxcb
    libx11
    libxcb-util
    libxcb-wm
    libxdmcp
    libxau
    libpulseaudio
    libnl
    libselinux
    libsepol
    yajl
    alsa-lib
    glib
    udev
    pcre2
    util-linux
    lua5
    docutils
  ];

  postInstall = ''
    wrapProgram $out/bin/luastatus-stdout-wrapper \
      --prefix LUASTATUS : $out/bin/luastatus

    wrapProgram $out/bin/luastatus-i3-wrapper \
      --prefix LUASTATUS : $out/bin/luastatus

    wrapProgram $out/bin/luastatus-lemonbar-launcher \
      --prefix LUASTATUS : $out/bin/luastatus
  '';

  meta = {
    description = "Universal status bar content generator";
    homepage = "https://github.com/shdown/luastatus";
    changelog = "https://github.com/shdown/luastatus/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ kashw2 ];
    platforms = lib.platforms.linux;
  };
})
