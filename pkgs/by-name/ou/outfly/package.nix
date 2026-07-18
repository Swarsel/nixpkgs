{
  lib,
  alsa-lib,
  fetchFromCodeberg,
  libGL,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  makeDesktopItem,
  nix-update-script,
  pkg-config,
  rustPlatform,
  vulkan-loader,
  wayland,
}:

rustPlatform.buildRustPackage rec {
  pname = "outfly";
  version = "0.15.0";

  src = fetchFromCodeberg {
    owner = "outfly";
    repo = "outfly";
    tag = "v${version}";
    hash = "sha256-BOm5SxpWowq5LCTqRqDkbKGPnZo0pJYz8w3kB/WnH9M=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    alsa-lib.dev
    libxcursor
    libxi
    wayland
  ];

  cargoHash = "sha256-UXqS4JfKuLxeTW1MDMnKLzw8oHf1Gpgv8SktTtf12mc=";
  doCheck = false; # no meaningful tests

  postFixup = ''
    patchelf $out/bin/outfly \
    --add-rpath ${lib.makeLibraryPath runtimeInputs}
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      desktopName = "OutFly";
      exec = "outfly";
      name = "outfly";
    })
  ];

  runtimeInputs = [
    libxkbcommon
    libGL
    libxrandr
    libx11
    vulkan-loader
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Breathtaking 3D space game in the rings of Jupiter";
    homepage = "https://yunicode.itch.io/outfly";
    changelog = "https://codeberg.org/outfly/outfly/releases/tag/v${version}";

    license = with lib.licenses; [
      cc-by-30
      cc-by-40
      cc-by-sa-20
      cc-by-sa-30
      cc0
      gpl3
      ofl
      publicDomain
    ];

    maintainers = with lib.maintainers; [ _71rd ];
    mainProgram = "outfly";
    downloadPage = "https://codeberg.org/outfly/outfly/releases";
  };
}
