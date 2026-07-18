{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_image,
  cmake,
  curl,
  freetype,
  giflib,
  gtest,
  libarchive,
  libjpeg,
  libpng,
  libwebp,
  libx11,
  libxi,
  lua,
  ninja,
  nixosTests,
  pixman,
  pkg-config,
  tinyxml-2,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libresprite";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "LibreSprite";
    repo = "LibreSprite";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jXjrA859hR46Cp5qi6Z1C+hLWCUR7yGlASOGlTveeW8=";
    fetchSubmodules = true;
  };

  patches = [
    # From https://github.com/LibreSprite/LibreSprite/pull/565
    ./cmake4.diff
    # Remove Homebrew-specific brew invocation for libarchive on Darwin;
    # Nix provides libarchive directly via buildInputs.
    ./no-brew.patch
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    ninja
    gtest
  ];

  buildInputs = [
    curl
    freetype
    giflib
    libjpeg
    libpng
    libwebp
    libarchive
    libx11
    pixman
    tinyxml-2
    zlib
    SDL2
    SDL2_image
    lua
    # no v8 due to missing libplatform and libbase
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    libxi
  ];

  cmakeFlags = [
    "-DWITH_DESKTOP_INTEGRATION=ON"
    "-DWITH_WEBP_SUPPORT=ON"
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ];

  # Install mime icons. Note that the mimetype is still "x-aseprite"
  postInstall = ''
    src="$out/share/libresprite/data/icons"
    for size in 16 32 48 64; do
      dst="$out"/share/icons/hicolor/"$size"x"$size"
      install -Dm644 "$src"/doc"$size".png "$dst"/mimetypes/aseprite.png
    done

    substituteInPlace $out/share/thumbnailers/libresprite.thumbnailer \
      --replace-fail "TryExec=libresprite-thumbnailer" "TryExec=$out/bin/libresprite-thumbnailer" \
      --replace-fail "Exec=libresprite-thumbnailer" "Exec=$out/bin/libresprite-thumbnailer"
  '';

  hardeningDisable = lib.optional stdenv.hostPlatform.isDarwin "format";

  passthru.tests = {
    libresprite-can-open-png = nixosTests.libresprite;
  };

  meta = {
    description = "Animated sprite editor & pixel art tool, fork of Aseprite";

    longDescription = ''
      LibreSprite is a program to create animated sprites. Its main features are:

        - Sprites are composed by layers & frames (as separated concepts).
        - Supported color modes: RGBA, Indexed (palettes up to 256 colors), and Grayscale.
        - Load/save sequence of PNG files and GIF animations (and FLC, FLI, JPG, BMP, PCX, TGA).
        - Export/import animations to/from Sprite Sheets.
        - Tiled drawing mode, useful to draw patterns and textures.
        - Undo/Redo for every operation.
        - Real-time animation preview.
        - Multiple editors support.
        - Pixel-art specific tools like filled Contour, Polygon, Shading mode, etc.
        - Onion skinning.
    '';

    homepage = "https://libresprite.github.io/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ fgaz ];
    platforms = lib.platforms.all;
  };
})
