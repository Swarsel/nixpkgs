{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  libx11,
  libxcb,
  libxcursor,
  libxext,
  libxfixes,
  libxi,
  libxinerama,
  libxkbcommon,
  libxpresent,
  libxrandr,
  mpv-unwrapped,
  pkg-config,
  rustPlatform,
  vulkan-loader,
  wayland,
  yt-dlp,
}:

rustPlatform.buildRustPackage rec {
  pname = "radiance";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "zbanks";
    repo = "radiance";
    rev = version;
    hash = "sha256-RWPcbUg7/gggPuUZLyMJ/m2S5GGfrdE6SWyXERIXsdk=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    mpv-unwrapped
    vulkan-loader
    libxkbcommon
    alsa-lib
    wayland
    libx11
    libxcursor
    libxi
    libxrandr
    libxinerama
    libxpresent
    libxfixes
    libxext
    libxcb
  ];

  cargoHash = "sha256-ESEFpGxqfDPOY1vrQk0IeOZiP8c5RNwPeKF3vRZRW0Q=";
  # Floating-point exact-equality bugs upstream
  doCheck = false;

  preFixup = ''
    patchelf \
      --add-rpath "${
        lib.makeLibraryPath [
          libxkbcommon
          libx11
          libxcursor
          libxi
          libxrandr
          libxinerama
          libxpresent
          libxfixes
          libxext
        ]
      }:$out/lib" \
      $out/bin/radiance \
      --add-needed libxkbcommon-x11.so
  '';

  propagatedUserEnvPkgs = [
    yt-dlp
  ];

  meta = {
    description = "Video art software for VJs";
    homepage = "https://github.com/zbanks/radiance";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ magnetophon ];
    platforms = lib.platforms.linux;
    mainProgram = "radiance";
  };
}
