{
  lib,
  SDL2,
  SDL2_gfx,
  SDL2_image,
  fetchFromCodeberg,
  fontconfig,
  freetype,
  libxkbcommon,
  nix-update-script,
  pkg-config,
  rustPlatform,
  wayland,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hail";
  version = "0.4.0";

  src = fetchFromCodeberg {
    owner = "periwinkle";
    repo = "hail";
    tag = finalAttrs.version;
    hash = "sha256-pPhbeZKNH5iKv4y34zKRmDIwLhmogaHIJJ00sZvHzHs=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    fontconfig
    freetype
    libxkbcommon
    wayland
    SDL2
    SDL2_image
    SDL2_gfx
  ];

  cargoHash = "sha256-TlxNHIpweWqRtoCblwUBS3RJM7vItORV8uYr4T3U37k=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Minimal speedrun timer";
    homepage = "https://codeberg.org/periwinkle/hail";
    changelog = "https://codeberg.org/periwinkle/hail/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ yiyu ];
    platforms = lib.platforms.linux;
    mainProgram = "hail";
  };
})
