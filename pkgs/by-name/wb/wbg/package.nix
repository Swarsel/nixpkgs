{
  lib,
  stdenv,
  fetchFromCodeberg,
  libjpeg,
  libjxl,
  # Optional dependencies
  libpng,
  libwebp,
  meson,
  ninja,
  pixman,
  pkg-config,
  tllist,
  wayland,
  wayland-protocols,
  wayland-scanner,
  enableJPEG ? true,
  enablePNG ? true,
  enableWebp ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wbg";
  version = "1.3.0";

  src = fetchFromCodeberg {
    owner = "dnkl";
    repo = "wbg";
    tag = finalAttrs.version;
    hash = "sha256-qEdl3dKeAfWWZ7+8MF59fAvtoELLA+C4680yFNsHhrY=";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    wayland-scanner
  ];

  buildInputs = [
    libjxl
    pixman
    tllist
    wayland
    wayland-protocols
  ]
  ++ lib.optional enablePNG libpng
  ++ lib.optional enableJPEG libjpeg
  ++ lib.optional enableWebp libwebp;

  mesonFlags = [
    (lib.mesonEnable "png" enablePNG)
    (lib.mesonEnable "jpeg" enableJPEG)
    (lib.mesonEnable "webp" enableWebp)
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-error=maybe-uninitialized"
  ];

  mesonBuildType = "release";

  meta = {
    description = "Wallpaper application for Wayland compositors";
    homepage = "https://codeberg.org/dnkl/wbg";
    changelog = "https://codeberg.org/dnkl/wbg/releases/tag/${finalAttrs.version}";
    license = lib.licenses.isc;
    maintainers = [ ];
    platforms = with lib.platforms; linux;
    mainProgram = "wbg";
  };
})
