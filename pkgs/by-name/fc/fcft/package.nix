{
  lib,
  stdenv,
  check,
  fcft, # for passthru.tests
  fetchFromCodeberg,
  fontconfig,
  freetype,
  harfbuzz,
  meson,
  nanosvg,
  ninja,
  pixman,
  pkg-config,
  scdoc,
  tllist,
  utf8proc,
  # Text shaping methods to enable, empty list disables all text shaping.
  # See `availableShapingTypes` or upstream meson_options.txt for available types.
  withShapingTypes ? [
    "grapheme"
    "run"
  ],
}:

let
  # Needs to be reflect upstream meson_options.txt
  availableShapingTypes = [
    "grapheme"
    "run"
  ];
in

stdenv.mkDerivation (finalAttrs: {
  pname = "fcft";
  version = "3.3.3";

  src = fetchFromCodeberg {
    owner = "dnkl";
    repo = "fcft";
    rev = finalAttrs.version;
    hash = "sha256-MkGlph9WpqH4daov5ZZPO2ua2mUbrsuo8Xk6GoKhoxg=";
  };

  outputs = [
    "out"
    "doc"
    "man"
  ];

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    scdoc
  ];

  buildInputs = [
    freetype
    fontconfig
    nanosvg
    pixman
    tllist
  ]
  ++ lib.optionals (withShapingTypes != [ ]) [ harfbuzz ]
  ++ lib.optionals (builtins.elem "run" withShapingTypes) [ utf8proc ];

  mesonFlags = [
    (lib.mesonEnable "system-nanosvg" true)
  ]
  ++ map (t: lib.mesonEnable "${t}-shaping" (lib.elem t withShapingTypes)) availableShapingTypes;

  doCheck = true;
  nativeCheckInputs = [ check ];
  depsBuildBuild = [ pkg-config ];
  mesonBuildType = "release";

  passthru.tests = {
    noShaping = fcft.override { withShapingTypes = [ ]; };
    onlyGraphemeShaping = fcft.override { withShapingTypes = [ "grapheme" ]; };
  };

  meta = {
    description = "Simple library for font loading and glyph rasterization";
    homepage = "https://codeberg.org/dnkl/fcft";
    changelog = "https://codeberg.org/dnkl/fcft/releases/tag/${finalAttrs.version}";

    license = with lib.licenses; [
      mit
      zlib
    ];

    maintainers = with lib.maintainers; [
      fionera
      sternenseemann
    ];

    platforms = with lib.platforms; linux;
  };
})
