{
  lib,
  fetchFromGitHub,
  SDL2,
  libGL,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  makeDesktopItem,
  makeWrapper,
  pkg-config,
  rustPlatform,
  wayland,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "snowemu";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "twvd";
    repo = "snow";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/arxD1bShXqsC2If2v7ARBsjdlnhlg0wK6MLX0q4xiI=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    SDL2.dev
    libx11
    libxcursor
    libxrandr
    libxi
  ];

  cargoHash = "sha256-7cyhpiT6RL+5x+xslQzhA5W71rcZ9TJPmfUHKl7TC/M=";

  postInstall = ''
    mv $out/bin/snow_frontend_egui $out/bin/snowemu

    install -Dm644 assets/snow_icon.png $out/share/icons/snowemu.png

    wrapProgram $out/bin/snowemu \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          wayland
          libxkbcommon
          libGL
        ]
      }
  '';

  desktopItems = makeDesktopItem {
    categories = [
      "Game"
      "Emulator"
    ];

    comment = finalAttrs.meta.description;
    desktopName = "Snow Emulator";
    exec = "snowemu";
    genericName = "Vintage Macintosh emulator";
    icon = "snowemu";
    name = "snowemu";
  };

  meta = {
    description = "Early Macintosh emulator";

    longDescription = ''
      Snow emulates classic (Motorola 680x0-based) Macintosh computers. It features a graphical user interface to operate the emulated machine and provides extensive debugging capabilities. The aim of this project is to emulate the Macintosh on a hardware-level as much as possible, as opposed to emulators that patch the ROM or intercept system calls.
      It currently emulates the Macintosh 128K, Macintosh 512K, Macintosh Plus, Macintosh SE, Macintosh Classic and Macintosh II.
    '';

    homepage = "https://snowemu.com/";
    changelog = "https://github.com/twvd/snow/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nulleric ];
    platforms = lib.platforms.linux;
    mainProgram = "snowemu";
  };
})
