{
  lib,
  fetchFromGitHub,
  cmake,
  copyDesktopItems,
  fontconfig,
  freetype,
  glib,
  gtk3,
  libGL,
  libx11,
  libxcb,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  makeDesktopItem,
  openssl,
  pkg-config,
  rustPlatform,
  wayland,
  withGui ? false, # build GUI version
}:

rustPlatform.buildRustPackage rec {
  pname = "rusty-psn";
  version = "0.5.10";

  src = fetchFromGitHub {
    owner = "RainbowCookie32";
    repo = "rusty-psn";
    tag = "v${version}";
    hash = "sha256-3sy3PBiV7ioRnYwI2vF6lGVj3Q/Ls6GmENyGePCgQ3k=";
  };

  nativeBuildInputs = [
    pkg-config
  ]
  ++ lib.optionals withGui [
    copyDesktopItems
    cmake
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals withGui [
    fontconfig
    glib
    gtk3
    freetype
    openssl
    libxcb
    libx11
    libxcursor
    libxrandr
    libxi
    libxcb
    libGL
    libxkbcommon
    wayland
  ];

  cargoHash = "sha256-orsCExYx9ZGtda13mmFk7665WFwZ7E7rr5wEcDxc+vY=";
  # Tests require network access
  doCheck = false;

  postFixup = ''
    patchelf --set-rpath "${lib.makeLibraryPath buildInputs}" $out/bin/rusty-psn
  ''
  + lib.optionalString withGui ''
    mv $out/bin/rusty-psn $out/bin/rusty-psn-gui
  '';

  buildFeatures = [ (if withGui then "egui" else "cli") ];
  buildNoDefaultFeatures = true;

  desktopItem = lib.optionalString withGui (makeDesktopItem {
    categories = [
      "Network"
    ];

    comment = "A simple tool to grab updates for PS3 games, directly from Sony's servers using their updates API.";
    desktopName = "rusty-psn";
    exec = "rusty-psn-gui";

    keywords = [
      "psn"
      "ps3"
      "sony"
      "playstation"
      "update"
    ];

    name = "rusty-psn";
  });

  desktopItems = lib.optionals withGui [ desktopItem ];

  meta = {
    description = "Simple tool to grab updates for PS3 games, directly from Sony's servers using their updates API";
    homepage = "https://github.com/RainbowCookie32/rusty-psn/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ AngryAnt ];
    platforms = [ "x86_64-linux" ];
    mainProgram = if withGui then "rusty-psn-gui" else "rusty-psn";
  };
}
