{
  lib,
  stdenv,
  fetchFromGitHub,
  check,
  cmake,
  dbus,
  filter-audio,
  fontconfig,
  freetype,
  libopus,
  libsodium,
  libtoxcore,
  libv4l,
  libvpx,
  libx11,
  libxext,
  libxft,
  libxrender,
  openal,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "utox";
  version = "0.18.1";

  src = fetchFromGitHub {
    owner = "uTox";
    repo = "uTox";
    tag = "v${version}";
    hash = "sha256-DxnolxUTn+CL6TbZHKLHOUMTHhtTSWufzzOTRpKjOwc=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 3.2)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libtoxcore
    dbus
    libvpx
    libx11
    openal
    freetype
    libv4l
    libxrender
    fontconfig
    libxext
    libxft
    filter-audio
    libsodium
    libopus
  ];

  cmakeFlags = [
    "-DENABLE_AUTOUPDATE=OFF"
    "-DENABLE_TESTS=${if doCheck then "ON" else "OFF"}"
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  nativeCheckInputs = [ check ];

  meta = {
    description = "Lightweight Tox client";
    homepage = "https://github.com/uTox/uTox";
    license = lib.licenses.gpl3;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "utox";
  };
}
