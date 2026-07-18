{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  SDL2,
  alsa-lib,
  autoreconfHook,
  binutils,
  fetchpatch2,
  ffmpeg,
  file,
  libxi,
  lua5_4,
  makeDesktopItem,
  pkg-config,
  qt5,
  # Forces libTAS to run in X11.
  # Enabled by default because libTAS does not support Wayland.
  withForceX11 ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libtas";
  version = "1.4.6";

  src = fetchFromGitHub {
    owner = "clementgallet";
    repo = "libTAS";
    rev = "v${finalAttrs.version}";
    hash = "sha256-/hyKJ8HGLN7hT+9If/lcp0C7GnhJMRpc7EKDgA1kQcI=";
  };

  patches = [
    # Fixes `undefined symbol: SDL_Log` errors
    (fetchurl {
      hash = "sha256-xAaTWIXt8FkMu6GE5mBWtLypROFZ1aEqmBTtG+6rTWk=";
      url = "https://github.com/clementgallet/libTAS/commit/779ff0fb0f3accfc62949680d85ecf96b28d18ef.patch";
    })
    # Fix build with gcc15
    (fetchpatch2 {
      hash = "sha256-vM1f6rvKIFyzEGJ7k+b/Zp4gAv8u6mdDUD5evV+hCJU=";
      url = "https://github.com/clementgallet/libTAS/commit/9699b158c522cf778bcdf626d0520fdd0a8b83aa.patch?full_index=1";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    qt5.wrapQtAppsHook
    pkg-config
  ];

  buildInputs = [
    SDL2
    alsa-lib
    ffmpeg
    lua5_4
    qt5.qtbase
  ];

  configureFlags = [
    "--enable-release-build"
  ];

  postInstall = ''
    mkdir -p $out/lib
    mv $out/bin/libtas*.so $out/lib/
  '';

  postFixup = ''
    wrapProgram $out/bin/libTAS \
      --suffix PATH : ${
        lib.makeBinPath [
          file
          binutils
          ffmpeg
        ]
      } \
      --suffix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libxi
          ffmpeg.lib
        ]
      } \
      ${lib.optionalString withForceX11 "--set QT_QPA_PLATFORM xcb"} \
      --set-default LIBTAS_SO_PATH $out/lib/libtas.so
  '';

  desktopItems = [
    (makeDesktopItem {
      desktopName = "libTAS";
      exec = "libTAS %U";
      icon = "libTAS";
      keywords = [ "libTAS" ];
      name = "libTAS";
      startupWMClass = "libTAS";
    })
  ];

  enableParallelBuilding = true;

  meta = {
    description = "GNU/Linux software to give TAS tools to games";
    homepage = "https://clementgallet.github.io/libTAS/";
    changelog = "https://github.com/clementgallet/libTAS/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ skyrina ];

    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];

    mainProgram = "libTAS";
  };
})
