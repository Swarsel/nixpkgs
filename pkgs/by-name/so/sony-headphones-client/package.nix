{
  lib,
  stdenv,
  fetchFromGitHub,
  bluez,
  cmake,
  copyDesktopItems,
  dbus,
  fetchpatch,
  glew,
  glfw,
  imgui,
  makeDesktopItem,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "SonyHeadphonesClient";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "Plutoberth";
    repo = "SonyHeadphonesClient";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vhI97KheKzr87exCh4xNN7NDefcagdMu1tWSt67vLiU=";
    fetchSubmodules = true;
  };

  patches = [
    (fetchpatch {
      extraPrefix = "";
      hash = "sha256-IZR/Znj40pUEC9gmNJDMPWuZOM2ueAgykZFn5DVn6es=";
      name = "include-cstdint-to-fix-gcc-compiling.patch";
      stripLen = 2;
      url = "https://github.com/Plutoberth/SonyHeadphonesClient/commit/4da8a12b22f8a45e79aa53d4cae88ca99b51d41f.patch";
    })
  ];

  postPatch = ''
    substituteInPlace Constants.h \
      --replace "UNKNOWN = -1" "// UNKNOWN removed since it doesn't fit in char"

    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 3.1 FATAL_ERROR)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    copyDesktopItems
  ];

  buildInputs = [
    bluez
    dbus
    glew
    glfw
    imgui
  ];

  cmakeFlags = [ "-Wno-dev" ];

  installPhase = ''
    runHook preInstall
    install -Dm755 -t $out/bin SonyHeadphonesClient
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Audio"
        "Mixer"
      ];

      comment = "A client recreating the functionality of the Sony Headphones app";
      desktopName = "Sony Headphones Client";
      exec = "SonyHeadphonesClient";
      icon = "SonyHeadphonesClient";
      name = "SonyHeadphonesClient";
    })
  ];

  sourceRoot = "${finalAttrs.src.name}/Client";

  meta = {
    description = "Client recreating the functionality of the Sony Headphones app";
    homepage = "https://github.com/Plutoberth/SonyHeadphonesClient";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ stunkymonkey ];
    platforms = lib.platforms.linux;
    mainProgram = "SonyHeadphonesClient";
  };
})
