{
  lib,
  stdenv,
  # Optional dependencies
  cairo,
  fcft,
  fetchFromCodeberg,
  libpng,
  librsvg,
  libxkbcommon,
  meson,
  ninja,
  pixman,
  pkg-config,
  resvg,
  scdoc,
  tllist,
  wayland,
  wayland-protocols,
  wayland-scanner,
  enableCairo ? true,
  pngSupport ? true,
  svgBackend ? "resvg", # alternative: "librsvg", "nanosvg"
  svgSupport ? true,
}:

assert (svgSupport && svgBackend == "nanosvg") -> enableCairo;

stdenv.mkDerivation (finalAttrs: {
  pname = "fuzzel";
  version = "1.14.1";

  src = fetchFromCodeberg {
    owner = "dnkl";
    repo = "fuzzel";
    rev = finalAttrs.version;
    hash = "sha256-VhUYNi0/NTrx84KxBgPP1bE2sN1HXqtayg4oY7BLZK4=";
  };

  nativeBuildInputs = [
    pkg-config
    wayland-scanner
    meson
    ninja
    scdoc
  ];

  buildInputs = [
    wayland
    pixman
    wayland-protocols
    libxkbcommon
    tllist
    fcft
  ]
  ++ lib.optional enableCairo cairo
  ++ lib.optional pngSupport libpng
  ++ lib.optional (svgSupport && svgBackend == "librsvg") librsvg
  ++ lib.optional (svgSupport && svgBackend == "resvg") resvg;

  mesonFlags = [
    (lib.mesonEnable "enable-cairo" enableCairo)
    (lib.mesonOption "png-backend" (if pngSupport then "libpng" else "none"))
    (lib.mesonOption "svg-backend" (if svgSupport then svgBackend else "none"))
  ];

  depsBuildBuild = [
    pkg-config
  ];

  mesonBuildType = "release";

  meta = {
    description = "Wayland-native application launcher, similar to rofi’s drun mode";
    homepage = "https://codeberg.org/dnkl/fuzzel";
    changelog = "https://codeberg.org/dnkl/fuzzel/releases/tag/${finalAttrs.version}";

    license = with lib.licenses; [
      mit
      zlib
    ];

    maintainers = with lib.maintainers; [
      fionera
      rodrgz
    ];

    platforms = with lib.platforms; linux;
    mainProgram = "fuzzel";
  };
})
