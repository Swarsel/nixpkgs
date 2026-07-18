{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  android-tools,
  ffmpeg,
  installShellFiles,
  libusb1,
  makeWrapper,
  meson,
  ninja,
  pkg-config,
  sdl3,
}:

let
  version = "4.1";
  prebuilt_server = fetchurl {
    inherit version;
    hash = "sha256-3qy5ke0lCXFRYP/ceQfke0Fg6zDRVmIX6QR/1biFDK4=";
    name = "scrcpy-server";
    url = "https://github.com/Genymobile/scrcpy/releases/download/v${version}/scrcpy-server-v${version}";
  };
in
stdenv.mkDerivation rec {
  inherit version;
  pname = "scrcpy";

  src = fetchFromGitHub {
    owner = "Genymobile";
    repo = "scrcpy";
    tag = "v${version}";
    hash = "sha256-x7ICNxR1i3WCPmYLsE/kmQ7vkNL9Be1M4m5SJMiXob4=";
  };

  nativeBuildInputs = [
    makeWrapper
    meson
    ninja
    pkg-config
    installShellFiles
  ];

  buildInputs = [
    ffmpeg
    sdl3
    libusb1
  ];

  # Manually install the server jar to prevent Meson from "fixing" it
  preConfigure = ''
    echo -n > server/meson.build
  '';

  postInstall = ''
    mkdir -p "$out/share/scrcpy"
    ln -s "${prebuilt_server}" "$out/share/scrcpy/scrcpy-server"

    # runtime dep on `adb` to push the server
    wrapProgram "$out/bin/scrcpy" --prefix PATH : "${android-tools}/bin"
  '';

  meta = {
    description = "Display and control Android devices over USB or TCP/IP";
    homepage = "https://github.com/Genymobile/scrcpy";
    changelog = "https://github.com/Genymobile/scrcpy/releases/tag/v${version}";
    license = lib.licenses.asl20;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode # server
    ];

    maintainers = with lib.maintainers; [
      deltaevo
      ryand56
    ];

    platforms = lib.platforms.unix;
    mainProgram = "scrcpy";
  };
}
